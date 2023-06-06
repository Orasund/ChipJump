import { playSound, setVolume, toggleMute } from "./sound";

export type MessageIn =
    { name: "playSound", sound: string[], instrument: string }
    | { name: "toggleMute" }
    | { name: "setVolume", amount: number }


export function evalMessage(message: MessageIn) {
    switch (message.name) {
        case "playSound":
            playSound(message.instrument, message.sound)
            return
        case "toggleMute":
            toggleMute()
            return
        case "setVolume":
            setVolume(message.amount)
            return
        default:
            return;
    }
}