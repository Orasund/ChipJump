import { playSound } from "./sound";

export type MessageIn =
    { name: "playSound", value: string[] }

export function evalMessage(message: MessageIn) {
    switch (message.name) {
        case "playSound":
            playSound(message.value)
        default:
            return;
    }
}