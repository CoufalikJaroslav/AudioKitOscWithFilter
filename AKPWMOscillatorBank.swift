//
//  AKPWMOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Pulse-Width Modulating Oscillator Bank
///
open class AKPWMOscillatorBank: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKPWMOscillatorBankAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "pwmb")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    /// Osc params
    fileprivate var pulseWidthParameter: AUParameter?
    /// Amp Envelope params
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?
    /// Filter Envelope params
    fileprivate var filterCutoffFrequencyParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?
    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?
    // Other params
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var vibratoRateParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /*
        Osc paramaters
    */

    /// Duty cycle width (range 0-1).
    @objc open dynamic var pulseWidth: Double = 0.5 {
        willSet {
            if pulseWidth != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        pulseWidthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.pulseWidth = Float(newValue)
                }
            }
        }
    }

    /*
        Amplitude Envelope paramaters
    */

    /// Attack time
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.attackDuration = Float(newValue)
                }
            }
        }
    }
    /// Decay time
    @objc open dynamic var decayDuration: Double = 0.1 {
        willSet {
            if decayDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        decayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.decayDuration = Float(newValue)
                }
            }
        }
    }
    /// Sustain Level
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        sustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.sustainLevel = Float(newValue)
                }
            }
        }
    }
    /// Release time
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.releaseDuration = Float(newValue)
                }
            }
        }
    }

    /*
        Moog Filter Envelope paramaters
    */

    /// Filter cutOff Requency
    @objc open dynamic var filterCutoffFrequency: Double = 22050.0 {
        willSet {
            if filterCutoffFrequency != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        filterCutoffFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterCutoffFrequency = Float(newValue)
                }
            }
        }
    }
    
    /// Filter resonance
    @objc open dynamic var filterResonance: Double = 22050.0 {
        willSet {
            if filterResonance != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        filterResonanceParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterResonance = Float(newValue)
                }
            }
        }
    }

    /// Filter attack time
    @objc open dynamic var filterAttackDuration: Double = 0.1 {
        willSet {
            if filterAttackDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        filterAttackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterAttackDuration = Float(newValue)
                }
            }
        }
    }
    /// Filter decay time
    @objc open dynamic var filterDecayDuration: Double = 0.1 {
        willSet {
            if filterDecayDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        filterDecayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterDecayDuration = Float(newValue)
                }
            }
        }
    }
    /// Filter sustain Level
    @objc open dynamic var filterSustainLevel: Double = 1.0 {
        willSet {
            if filterSustainLevel != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        filterSustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterSustainLevel = Float(newValue)
                }
            }
        }
    }
    /// Filter release time
    @objc open dynamic var filterReleaseDuration: Double = 0.1 {
        willSet {
            if filterReleaseDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        filterReleaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.filterReleaseDuration = Float(newValue)
                }
            }
        }
    }

    /*
       Others paramaters
    */

    /// Pitch Bend as number of semitones
    @objc open dynamic var pitchBend: Double = 0 {
        willSet {
            if pitchBend != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        pitchBendParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.pitchBend = Float(newValue)
                }
            }
        }
    }

    /// Vibrato Depth in semitones
    @objc open dynamic var vibratoDepth: Double = 0 {
        willSet {
            if vibratoDepth != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        vibratoDepthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.vibratoDepth = Float(newValue)
                }
            }
        }
    }

    /// Vibrato Rate in Hz
    @objc open dynamic var vibratoRate: Double = 0 {
        willSet {
            if vibratoRate != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        vibratoRateParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.vibratoRate = Float(newValue)
                }
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(pulseWidth: 0.5)
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - pulseWidth: Duty cycle width (range 0-1).
    ///   - attackDuration: Attack time
    ///   - decayDuration: Decay time
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release time
    ///   - filterCutoffFrequency: Filter cutoff frequency
    ///   - filterResonance: Filter resonance
    ///   - filterAttackDuration: Filter attack time
    ///   - filterDecayDuration: Filter decay time
    ///   - filterSustainLevel: Filter sustain Level
    ///   - filterReleaseDuration: Filter release time
    ///   - pitchBend: Change of pitch in semitones
    ///   - vibratoDepth: Vibrato size in semitones
    ///   - vibratoRate: Frequency of vibrato in Hz

    ///
    @objc public init(
        pulseWidth: Double = 0.5,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1,
        filterCutoffFrequency: Double = 22050.0,
        filterResonance: Double = 0.0,
        filterAttackDuration: Double = 0.1,
        filterDecayDuration: Double = 0.1,
        filterSustainLevel: Double = 1.0,
        filterReleaseDuration: Double = 0.1,
        pitchBend: Double = 0,
        vibratoDepth: Double = 0,
        vibratoRate: Double = 0) {

        self.pulseWidth = pulseWidth
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.filterCutoffFrequency = filterCutoffFrequency
        self.filterResonance = filterResonance
        self.filterAttackDuration = filterAttackDuration
        self.filterDecayDuration = filterDecayDuration
        self.filterSustainLevel = filterSustainLevel
        self.filterReleaseDuration = filterReleaseDuration
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.vibratoRate = vibratoRate

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        pulseWidthParameter = tree["pulseWidth"]
        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]
        filterCutoffFrequencyParameter = tree["filterCutoffFrequency"]
        filterResonanceParameter = tree["filterResonance"]
        filterAttackDurationParameter = tree["filterAttackDuration"]
        filterDecayDurationParameter = tree["filterDecayDuration"]
        filterSustainLevelParameter = tree["filterSustainLevel"]
        filterReleaseDurationParameter = tree["filterReleaseDuration"]
        pitchBendParameter = tree["pitchBend"]
        vibratoDepthParameter = tree["vibratoDepth"]
        vibratoRateParameter = tree["vibratoRate"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        internalAU?.pulseWidth = Float(pulseWidth)
        internalAU?.attackDuration = Float(attackDuration)
        internalAU?.decayDuration = Float(decayDuration)
        internalAU?.sustainLevel = Float(sustainLevel)
        internalAU?.releaseDuration = Float(releaseDuration)
        internalAU?.filterCutoffFrequency = Float(filterCutoffFrequency)
        internalAU?.filterResonance = Float(filterResonance)
        internalAU?.filterAttackDuration = Float(filterAttackDuration)
        internalAU?.filterDecayDuration = Float(filterDecayDuration)
        internalAU?.filterSustainLevel = Float(filterSustainLevel)
        internalAU?.releaseDuration = Float(filterReleaseDuration)
        internalAU?.pitchBend = Float(pitchBend)
        internalAU?.vibratoDepth = Float(vibratoDepth)
        internalAU?.vibratoRate = Float(vibratoRate)
    }

    // MARK: - AKPolyphonic

    // Function to start, play, or activate the node at frequency
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: Float(frequency))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
