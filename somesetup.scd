SuperDirt.start;
~dirt.loadSoundFiles("~/workspace/Dirt/samples/*")


(
 SynthDef(\sc303, {|out, freq=440, wave=0, ctf=100, res=0.2,
		sus=0, dec=1.0, env=1000, gate=0, vol=0.5, pan=0.5|
	 var  filEnv, volEnv, waves, sound;

	 // can't use adsr with exp curve???
	 //volEnv = EnvGen.ar(Env.adsr(1, 0, 1, dec, vol, 'exp'), In.kr(bus));
	volEnv =  EnvGen.ar( Env.new([10e-10, 1, 1, 10e-10], [0.01, sus, dec], 'exp'), gate);
	filEnv =  EnvGen.ar( Env.new([10e-10, 1, 10e-10], [0.01, dec], 'exp'), gate);

	waves = [Saw.ar(freq, volEnv), Pulse.ar(freq, 0.5, volEnv)];
	sound = RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res);
	//sound = sound.dup * vol;
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add
);

// physical modeling of a vibrating string, using a delay line (CombL) excited by an intial pulse (Impulse)
// To make it a bit richer, I've combined two slightly detuned delay lines
// "accelerate" is used for a pitch glide, and "sustain" changes the envelope timescale
(
	SynthDef(\supermandolin, {|out, sustain=1, pan, accelerate, freq, detune=0.2 |
		var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
		var sound = Decay.ar(Impulse.ar(0,0,0.1), 0.1*(freq.cpsmidi)/69) * WhiteNoise.ar;
		var pitch = freq * Line.kr(1, 1+accelerate, sustain);
		sound = CombL.ar(sound, 0.05, pitch.reciprocal*(1-(detune/100)), sustain)
		+ CombL.ar(sound, 0.05, pitch.reciprocal*(1+(detune/100)), sustain);
		OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
	}).add
);


(
SynthDef(\tutorial5, {|out, sustain=1, pan, accelerate, f |
	var env = EnvGen.ar(Env.perc(0.001, 0.999, 1, -4), timeScale:sustain, doneAction:2);
	var sound = SinOsc.ar(f * Line.kr(1,1+accelerate, sustain));
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add
);


(
SynthDef(\tutorial1, {|out|
	var sound = SinOsc.ar(440.0);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, 0.5));
}).add
);


(
SynthDef(\acid, { |out, freq = 1000, gate = 1, pan = 1, cut = 4000, rez = 0.8, amp = 1|
	var env = EnvGen.kr(Env.linen(0.01, 1, 0.3), gate, amp, doneAction:2);
	var sound = RLPF.ar(Pulse.ar(freq, 0.05), cut, rez);
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add;
)


(
SynthDef(\acid, { arg out=0, freq=80, amp=1.0, pan=0, gate=20;
	var synth, env;
	env = Decay2.kr(gate, 0.05, 8, 0.0003);
	synth = RLPF.ar(
		LFPulse.ar(freq, 0, SinOsc.kr(0.12, [0, 0.5pi], 0.48, 0.5)),
		freq * SinOsc.kr(0.21, 0, 18, 20),
		0.07
	);
	#a, b = synth*env;
	DetectSilence.ar(a, 0.1, doneAction: 2);
	Out.ar(out, amp * Mix.ar(PanAz.ar(4, [a, b], [pan, pan+1])));
}).add;
)

(
SynthDef(\acid, { arg out, freq = 432, gate = 1, pan = 1, cut = 4000, rez = 0.8, amp = 1;
	Out.ar(out,
		Pan2.ar(
			RLPF.ar(
				Pulse.ar(freq, 0.05),
			cut, rez),
		pan) * EnvGen.kr(Env.linen(0.01, 1, 0.3), gate, amp, doneAction:2);
	)
}).add;
)
