import * as Tone from 'tone'

//create a synth and connect it to the main output (your speakers)
const synth = new Tone.Synth().toDestination();

//create a sampler and connect it to the main output (your speaker)
const sampler = new Tone.Sampler({
    urls: {
        A1: "A1.mp3",
        A2: "A2.mp3",
    },
    baseUrl: "https://tonejs.github.io/audio/casio/",
    onload: () => {
        sampler.triggerAttackRelease(["C1", "E1", "G1", "B1"], 0.5);
        //play a middle 'C' for the duration of an 8th note
        synth.triggerAttackRelease("C4", "8n");
    }
}).toDestination();

export function playSound(notes: string[]) {
    sampler.triggerAttackRelease(["C2"], 0.5);
}