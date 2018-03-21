//
//  ViewController.swift
//  sdfs
//
//  Created by Jaroslav Coufalik on 18/03/2018.
//  Copyright © 2018 Jaroslav Coufalik. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController, AKKeyboardDelegate {
    
    let oscillator = AKPWMOscillatorBank()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oscillator.filterCutoffFrequency = 440
        oscillator.filterResonance = 0.5
        
        AudioKit.output = oscillator
        try! AudioKit.start()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func noteOn(note: MIDINoteNumber) {
        oscillator.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: MIDINoteNumber) {
        oscillator.stop(noteNumber: note)
    }
    
    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let subStackView = UIStackView()
        subStackView.axis = .horizontal
        subStackView.distribution = .fillEqually
        subStackView.alignment = .fill
        subStackView.translatesAutoresizingMaskIntoConstraints = false
        let adsrViewAmp = AKADSRView() { att, dec, sus, rel in
            self.oscillator.attackDuration = att
            self.oscillator.decayDuration = dec
            self.oscillator.sustainLevel = sus
            self.oscillator.releaseDuration = rel
        }
        subStackView.addArrangedSubview(adsrViewAmp)
        
        let adsrViewFilter = AKADSRView() { att, dec, sus, rel in
            self.oscillator.filterAttackDuration = att
            self.oscillator.filterDecayDuration = dec
            self.oscillator.filterSustainLevel = sus
            self.oscillator.filterReleaseDuration = rel
        }
        subStackView.addArrangedSubview(adsrViewFilter)
        
        stackView.addArrangedSubview(subStackView)
        
        let keyboardView = AKKeyboardView()
        stackView.addArrangedSubview(keyboardView)
        keyboardView.delegate = self
        keyboardView.firstOctave = 0
        keyboardView.octaveCount = 7
        
        view.addSubview(stackView)
        
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
}

