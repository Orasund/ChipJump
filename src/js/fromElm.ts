import { playSound } from "./sound";

export type MessageIn =
    { name: "playSound", sound: string[], instrument: string }

export function evalMessage(message: MessageIn) {
    switch (message.name) {
        case "playSound":
            playSound(message.instrument, message.sound)
        default:
            return;
    }
}