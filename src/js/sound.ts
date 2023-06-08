import * as Tone from 'tone'

const limiter = new Tone.Limiter(-20).toDestination();

//create a synth and connect it to the main output (your speakers)
const synth = new Tone.PolySynth().connect(limiter);
synth.set({ detune: -1200 })



//create a sampler and connect it to the main output (your speaker)
const sampler = new Tone.Sampler({
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
            sampler.triggerAttackRelease(notes, 0.5);
            return;
    }
}

export function toggleMute() {
    Tone.Destination.mute = !Tone.Destination.mute
}

export function setVolume(amount: number) {
    Tone.Destination.volume.value = 24 * amount
}