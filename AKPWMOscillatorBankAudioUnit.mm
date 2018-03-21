//
//  AKPWMOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>

#import "AKPWMOscillatorBankAudioUnit.h"
#import "AKPWMOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKPWMOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPWMOscillatorBankDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;
- (void)setPulseWidth:(float)pulseWidth {
    _kernel.setPulseWidth(pulseWidth);
}
- (void)setFilterCutoffFrequency:(float)filterCutoffFrequency {
    _kernel.setFilterCutoffFrequency(filterCutoffFrequency);
}
- (void)setFilterResonance:(float)filterResonance {
    _kernel.setFilterResonance(filterResonance);
}
- (void)setFilterAttackDuration:(float)filterAttackDuration { 
    _kernel.setFilterAttackDuration(filterAttackDuration);
}
- (void)setFilterDecayDuration:(float)filterDecayDuration {
    _kernel.setFilterDecayDuration(filterDecayDuration);
}
- (void)setFilterSustainLevel:(float)filterSustainLevel {
    _kernel.setFilterSustainLevel(filterSustainLevel);
}
- (void)setFilterReleaseDuration:(float)filterReleaseDuration {
    _kernel.setFilterReleaseDuration(filterReleaseDuration);
}

standardBankFunctions()

- (void)createParameters {

    standardGeneratorSetup(PWMOscillatorBank)
    standardBankParameters(AKPWMOscillatorBankDSPKernel)

    /*
        Oscillator paramaters
    */
    
    // Create a parameter object for the pulseWidth.
    AUParameter *pulseWidthAUParameter = [AUParameter parameter:@"pulseWidth"
                                                           name:@"Pulse Width"
                                                        address:AKPWMOscillatorBankDSPKernel::pulseWidthAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    pulseWidthAUParameter.value = 0.5;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::pulseWidthAddress, pulseWidthAUParameter.value);

    // ----- Filter Cutoff Frequency -----
    // Create a parameter object for the filterCutoffFrequency.
    AUParameter *filterCutoffFrequencyAUParameter = [AUParameter parameter:@"filterCutoffFrequency"
                                                           name:@"Filter Cutoff Frequency"
                                                        address:AKPWMOscillatorBankDSPKernel::filterCutoffFrequencyAddress
                                                            min:0.0
                                                            max:22050.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    filterCutoffFrequencyAUParameter.value = 22050.0;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::filterCutoffFrequencyAddress, filterCutoffFrequencyAUParameter.value);

    // ----- Filter Resonance Frequency -----
    // Create a parameter object for the filterResonance.
    AUParameter *filterResonanceAUParameter = [AUParameter parameter:@"filterResonance"
                                                           name:@"Filter Resonance"
                                                        address:AKPWMOscillatorBankDSPKernel::filterResonanceAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    filterResonanceAUParameter.value = 0.0;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::filterResonanceAddress, filterResonanceAUParameter.value);

    /*
        Filter Envelope paramaters
    */

    // ----- Attack -----
    // Create a parameter object for the filterAttackDuration.
    AUParameter *filterAttackDurationAUParameter = [AUParameter parameter:@"filterAttackDuration"
                                                           name:@"Filter Attack Duration"
                                                        address:AKPWMOscillatorBankDSPKernel::filterAttackDurationAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    filterAttackDurationAUParameter.value = 0.1;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::filterAttackDurationAddress, filterAttackDurationAUParameter.value);

    // ----- Decay -----
    // Create a parameter object for the filterDecayDuration.
    AUParameter *filterDecayDurationAUParameter = [AUParameter parameter:@"filterDecayDuration"
                                                           name:@"Filter Decay Duration"
                                                        address:AKPWMOscillatorBankDSPKernel::filterDecayDurationAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    filterDecayDurationAUParameter.value = 0.1;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::filterDecayDurationAddress, filterDecayDurationAUParameter.value);

    // ----- Sustain -----
    // Create a parameter object for the filterSustainLevel.
    AUParameter *filterSustainLevelAUParameter = [AUParameter parameter:@"filterSustainLevel"
                                                           name:@"Filter Sustain Level"
                                                        address:AKPWMOscillatorBankDSPKernel::filterSustainLevelAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    filterSustainLevelAUParameter.value = 1.0;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::filterSustainLevelAddress, filterSustainLevelAUParameter.value);

    // ----- Release -----
    // Create a parameter object for the filterReleaseDuration.
    AUParameter *filterReleaseDurationAUParameter = [AUParameter parameter:@"filterReleaseDuration"
                                                           name:@"Filter Release Duration"
                                                        address:AKPWMOscillatorBankDSPKernel::filterReleaseDurationAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    filterReleaseDurationAUParameter.value = 0.1;

    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::filterReleaseDurationAddress, filterReleaseDurationAUParameter.value);


    /*
        Add paramaters
    */

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
                                                               standardBankAUParameterList(),
                                                               pulseWidthAUParameter,
                                                               filterCutoffFrequencyAUParameter,
                                                               filterResonanceAUParameter,
                                                               filterAttackDurationAUParameter,
                                                               filterDecayDurationAUParameter,
                                                               filterSustainLevelAUParameter,
                                                               filterReleaseDurationAUParameter
                                                               ]];

    parameterTreeBlock(PWMOscillatorBank)
}

AUAudioUnitGeneratorOverrides(PWMOscillatorBank)

@end


