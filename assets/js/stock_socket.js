import {Socket} from "phoenix"

let socket = new Socket("/socket", {})

socket.connect()


const outgoing_stock_channel = socket.channel("outgoingstock:latest")
    outgoing_stock_channel.join()
        .receive("ok", (response) => {console.log("Joined outgoing stock successfully", response)})
        .receive("error", (response) => {console.log("Unable to join outgoing stock", response)})


        if (document.querySelector("#incoming-channel")){
            let joinIncomingChannel = document.querySelector("#incoming-channel")
    
            joinIncomingChannel.addEventListener("click", function() {
                const incoming_stock_channel = socket.channel("incomingstock:latest")
                incoming_stock_channel.join()
                    .receive("ok", (response) => {console.log("Joined incoming stock successfully", response)})
                    .receive("error", (response) => {console.log("Unable to join incoming stock", response)})
            })
        }



export default socket