import * as Tone from 'tone'
import { Volume } from 'tone';

const limiter = new Tone.Limiter(-12).toDestination();
const volume = new Tone.Volume().connect(limiter);
volume.volume.value = -12

//create a synth and connect it to the main output (your speakers)
const synth = new Tone.PolySynth(Tone.Synth, {
    "portamento": 0.0,
    "oscillator": {
        "type": "square4"
    },
    "envelope": {
        "attack": 2,
        "decay": 1,
        "sustain": 0.2,
        "release": 8
    }
})
    .connect(new Tone.FeedbackDelay("4n", 0.5).connect(volume))
    .connect(volume);


const salamander = new Tone.Sampler({
    urls: {
        A1: "A1.mp3",
        A2: "A2.mp3",
    },
    baseUrl: "assets/samples/salamander/",
    onload: () => { }
})
    .connect(new Tone.FeedbackDelay("8n", 0.5).connect(volume))
    .connect(volume);

const casio = new Tone.Sampler({
    urls: {
        A1: "A1.mp3",
        A2: "A2.mp3",
    },
    baseUrl: "assets/samples/casio/",
    onload: () => { }
})
    .connect(limiter);

export function playSound(instrument: string, notes: string[]) {
    switch (instrument) {
        case "waveInstrument":
            synth.triggerAttackRelease(notes, 1);
            return;
        case "lilyPadInstrument":
            casio.triggerAttackRelease(notes, 0.5);
            return;
    }
}

export function toggleMute() {
    Tone.Destination.mute = !Tone.Destination.mute
}

export function setVolume(amount: number) {
    Tone.Destination.volume.value = 24 * amount
}