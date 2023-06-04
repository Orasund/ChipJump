import * as Tone from 'tone'

//create a synth and connect it to the main output (your speakers)
const synth = new Tone.Synth().toDestination();

//create a sampler and connect it to the main output (your speaker)
const sampler = new Tone.Sampler({
    urls: {
        A1: "A1.mp3",
        A2: "A2.mp3",
    },
    baseUrl: "assets/samples/casio/",
    onload: () => { }
}).toDestination();

export function playSound(notes: string[]) {
    sampler.triggerAttackRelease(notes, 0.5);
}