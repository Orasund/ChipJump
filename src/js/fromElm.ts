import { playSound } from "./sound";

export type MessageIn =
    { name: "playSound", sound: string[] }

export function evalMessage(message: MessageIn) {
    switch (message.name) {
        case "playSound":
            playSound(message.sound)
        default:
            return;
    }
}