import * as Tone from 'tone'

//volumne
const vol = new Tone.Volume(-12).toDestination();


//create a synth and connect it to the main output (your speakers)
const synth = new Tone.PolySynth().connect(vol).toDestination();
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
    .connect(vol)
    .toDestination();

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
    vol.mute = !vol.mute
}

export function setVolume(amount: number) {
    vol.volume.value = -12 * amount
}