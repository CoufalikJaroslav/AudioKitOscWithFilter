//
//  AKPWMOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKBankDSPKernel.hpp"

class AKPWMOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
public:
    // MARK: Types
    
    enum {
        standardBankEnumElements(),
        pulseWidthAddress = numberOfBankEnumElements,
        filterCutoffFrequencyAddress = numberOfBankEnumElements + 1,
        filterResonanceAddress = numberOfBankEnumElements + 2,
        filterAttackDurationAddress = numberOfBankEnumElements + 3,
        filterDecayDurationAddress = numberOfBankEnumElements + 4,
        filterSustainLevelAddress = numberOfBankEnumElements + 5,
        filterReleaseDurationAddress = numberOfBankEnumElements + 6
    };
    
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        AKPWMOscillatorBankDSPKernel* kernel;

        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;

        float internalGate = 0;
        float amp = 0;
        float filterAmp = 0;

        sp_adsr *adsr;
        sp_blsquare *blsquare;

        sp_adsr *filteradsr;
        sp_moogladder *moogladder;

        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);

            sp_blsquare_create(&blsquare);
            sp_blsquare_init(kernel->sp, blsquare);
            *blsquare->freq = 0;
            *blsquare->amp = 0;
            *blsquare->width = 0.5;

            sp_adsr_create(&filteradsr);
            sp_adsr_init(kernel->sp, filteradsr);

            sp_moogladder_create(&moogladder);
            sp_moogladder_init(kernel->sp, moogladder);
            moogladder->freq = 22050.0;
            moogladder->res = 0;
        }

        void clear() {
            stage = stageOff;
            amp = 0;
            filterAmp = 0;
        }

        // linked list management
        void remove() {
            if (prev) prev->next = next;
            else kernel->playingNotes = next;

            if (next) next->prev = prev;

            //prev = next = nullptr; Had to remove due to a click, potentially bad

            --kernel->playingNotesCount;

            sp_moogladder_destroy(&moogladder);
            sp_blsquare_destroy(&blsquare);
        }

        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }

        void noteOn(int noteNumber, int velocity) {
            noteOn(noteNumber, velocity, (float)noteToHz(noteNumber));
        }

        void noteOn(int noteNumber, int velocity, float frequency) {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                *blsquare->freq = frequency;
                *blsquare->amp = (float)pow2(velocity / 127.);
                moogladder->freq = 22050.0f;
                stage = stageOn;
                internalGate = 1;
            }
        }


        void run(int frameCount, float* outL, float* outR)
        {
            float originalFrequency = *blsquare->freq;
            *blsquare->freq *= powf(2, kernel->pitchBend / 12.0);
            *blsquare->freq = clamp(*blsquare->freq, 0.0f, 22050.0f);
            float bentFrequency = *blsquare->freq;

            *blsquare->width = kernel->pulseWidth;

            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;

            float sff = (float)kernel->filterCutoffFrequency;
            float sfr = (float)kernel->filterResonance;
            moogladder->freq = kernel->filterCutoffFrequency;
            moogladder->res = kernel->filterResonance;

            filteradsr->atk = (float)kernel->filterAttackDuration;
            filteradsr->dec = (float)kernel->filterDecayDuration;
            filteradsr->sus = (float)kernel->filterSustainLevel;
            filteradsr->rel = (float)kernel->filterReleaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->sampleRate);
                *blsquare->freq = bentFrequency * powf(2, depth * variation);
                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);
                sp_blsquare_compute(kernel->sp, blsquare, nil, &x);

                float xf = x;

                // compute evelope filter
                sp_adsr_compute(kernel->sp, filteradsr, &internalGate, &filterAmp);
                moogladder->freq = sff + ((22050.0f - sff) * filterAmp);
                moogladder->freq = clamp(moogladder->freq, 0.0f, 22050.0f);
                sp_moogladder_compute(kernel->sp, moogladder, &x, &xf);
                
                *outL++ += amp * xf;
                *outR++ += amp * xf;
            }
            *blsquare->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }

    };

    // MARK: Member Functions

    AKPWMOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
    }

    void init(int _channels, double _sampleRate) override {
        AKBankDSPKernel::init(_channels, _sampleRate);
        pulseWidthRamper.init();
        filterCutoffFrequencyRamper.init();
        filterResonanceRamper.init();
        filterAttackDurationRamper.init();
        filterDecayDurationRamper.init();
        filterSustainLevelRamper.init();
        filterReleaseDurationRamper.init();
    }

    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        pulseWidthRamper.reset();
        filterCutoffFrequencyRamper.reset();
        filterResonanceRamper.reset();
        filterAttackDurationRamper.reset();
        filterDecayDurationRamper.reset();
        filterSustainLevelRamper.reset();
        filterReleaseDurationRamper.reset();
        AKBankDSPKernel::reset();
    }

    standardBankKernelFunctions()

    void setPulseWidth(float value) {
        pulseWidth = clamp(value, 0.0f, 1.0f);
        pulseWidthRamper.setImmediate(pulseWidth);
    }

    void setFilterCutoffFrequency(float value) {
        filterCutoffFrequency = clamp(value, 0.0f, 22050.0f);
        filterCutoffFrequencyRamper.setImmediate(filterCutoffFrequency);
    }

    void setFilterResonance(float value) {
        filterResonance = clamp(value, 0.0f, 1.0f);
        filterResonanceRamper.setImmediate(filterResonance);
    }

    void setFilterAttackDuration(float value) {
        filterAttackDuration = clamp(value, 0.0f, 99.0f);
        filterAttackDurationRamper.setImmediate(filterAttackDuration);
    }

    void setFilterDecayDuration(float value) {
        filterDecayDuration = clamp(value, 0.0f, 99.0f);
        filterDecayDurationRamper.setImmediate(filterDecayDuration);
    }

    void setFilterSustainLevel(float value) {
        filterSustainLevel = clamp(value, 0.0f, 99.0f);
        filterSustainLevelRamper.setImmediate(filterSustainLevel);
    }

    void setFilterReleaseDuration(float value) {
        filterReleaseDuration = clamp(value, 0.0f, 99.0f);
        filterReleaseDurationRamper.setImmediate(filterReleaseDuration);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {

            case pulseWidthAddress:
                pulseWidthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            case filterCutoffFrequencyAddress:
                filterCutoffFrequencyRamper.setUIValue(clamp(value, 0.0f, 22050.0f));
                break;
            case filterResonanceAddress:
                filterResonanceRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            case filterAttackDurationAddress:
                filterAttackDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterDecayDurationAddress:
                filterDecayDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterSustainLevelAddress:
                filterSustainLevelRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterReleaseDurationAddress:
                filterReleaseDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
                standardBankSetParameters()
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case pulseWidthAddress:
                return pulseWidthRamper.getUIValue();
            case filterCutoffFrequencyAddress:
                return filterCutoffFrequencyRamper.getUIValue();
            case filterResonanceAddress:
                return filterResonanceRamper.getUIValue();
            case filterAttackDurationAddress:
                return filterAttackDurationRamper.getUIValue();
            case filterDecayDurationAddress:
                return filterDecayDurationRamper.getUIValue();
            case filterSustainLevelAddress:
                return filterSustainLevelRamper.getUIValue();
            case filterReleaseDurationAddress:
                return filterReleaseDurationRamper.getUIValue();
                standardBankGetParameters()
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {

            case pulseWidthAddress:
                pulseWidthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            case filterCutoffFrequencyAddress:
                filterCutoffFrequencyRamper.startRamp(clamp(value, 0.0f, 22050.0f), duration);
                break;
            case filterResonanceAddress:
                filterResonanceRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            case filterAttackDurationAddress:
                filterAttackDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterDecayDurationAddress:
                filterDecayDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterSustainLevelAddress:
                filterSustainLevelRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterReleaseDurationAddress:
                filterReleaseDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
                standardBankStartRamps()
        }
    }

    standardHandleMIDI()

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        pulseWidth = double(pulseWidthRamper.getAndStep());
        filterCutoffFrequency = double(filterCutoffFrequencyRamper.getAndStep());
        filterResonance = double(filterResonanceRamper.getAndStep());
        filterAttackDuration = filterAttackDurationRamper.getAndStep();
        filterDecayDuration = filterDecayDurationRamper.getAndStep();
        filterSustainLevel = filterSustainLevelRamper.getAndStep();
        filterReleaseDuration = filterReleaseDurationRamper.getAndStep();
        standardBankGetAndSteps()

        NoteState* noteState = playingNotes;
        while (noteState) {
            noteState->run(frameCount, outL, outR);
            noteState = noteState->next;
        }
        currentRunningIndex += frameCount / 2;

        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] *= .5f;
            outR[i] *= .5f;
        }
    }

    // MARK: Member Variables

private:
    std::vector<NoteState> noteStates;

    float pulseWidth = 0.5;

    float filterCutoffFrequency = 22050.0;
    float filterResonance = 0.0;
    float filterAttackDuration = 0.1;
    float filterDecayDuration = 0.1;
    float filterSustainLevel = 1.0;
    float filterReleaseDuration = 0.1;

public:
    NoteState* playingNotes = nullptr;

    ParameterRamper pulseWidthRamper = 0.5;

    ParameterRamper filterCutoffFrequencyRamper = 0.1;
    ParameterRamper filterResonanceRamper = 0.1;
    ParameterRamper filterAttackDurationRamper = 0.1;
    ParameterRamper filterDecayDurationRamper = 0.1;
    ParameterRamper filterSustainLevelRamper = 1.0;
    ParameterRamper filterReleaseDurationRamper = 0.1;
};

#endif

