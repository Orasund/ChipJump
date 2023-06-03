import { evalMessage, type MessageIn } from "./js/fromElm";

export function fromElm(message: MessageIn) {
    evalMessage(message)
}

(<any>window).fromElm = fromElm