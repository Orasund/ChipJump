import * as Tone from 'tone'
import { Volume } from 'tone';

const limiter = new Tone.Limiter(0).toDestination();

const synthVolume = new Tone.Volume(-18).connect(limiter);
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
}).fan(new Tone.FeedbackDelay("4n", 0.5).connect(synthVolume), synthVolume);


const salamander = new Tone.Sampler({
    urls: {
        A1: "A1.mp3",
        A2: "A2.mp3",
    },
    baseUrl: "assets/samples/salamander/",
    onload: () => { }
})
    .chain(new Tone.FeedbackDelay("8n", 0.5), new Tone.Volume(-12), limiter);

const casio = new Tone.Sampler({
    urls: {
        A1: "A1.mp3",
        A2: "A2.mp3",
    },
    baseUrl: "assets/samples/casio/",
    onload: () => { }
})
    .chain(new Tone.Volume(-12), limiter);

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