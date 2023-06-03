import { playSound } from "./sound";

type MessageIn =
    { name: "playSound", value: string[] }

export function evalMessage(string: string) {
    const message: MessageIn = JSON.parse(string)

    switch (message.name) {
        case "playSound":
            playSound(message.value)
        default:
            return;
    }
}