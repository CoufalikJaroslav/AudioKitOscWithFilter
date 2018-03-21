//
//  AKPWMOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKBankAudioUnit.h"

@interface AKPWMOscillatorBankAudioUnit : AKBankAudioUnit

@property (nonatomic) float pulseWidth;
@property (nonatomic) float filterCutoffFrequency;
@property (nonatomic) float filterResonance;
@property (nonatomic) float filterAttackDuration;
@property (nonatomic) float filterDecayDuration;
@property (nonatomic) float filterSustainLevel;
@property (nonatomic) float filterReleaseDuration;

@end
