import gleam/erlang/process
import gleam/list
import gleam/otp/actor
import gleam/result

pub type Link {
  Link(id: Int, url: String, title: String)
}

pub type Message {
  Add(url: String, title: String)
  GetAll(reply_with: process.Subject(List(Link)))
  Shutdown
}

// Start the link store actor with List(Link) as its state
pub fn start() -> Result(process.Subject(Message), actor.StartError) {
  let initial_state = []
  actor.new(initial_state)
  |> actor.on_message(handle_message)
  |> actor.start
  |> result.map(fn(started_actor) { started_actor.data })
}

// Handle messages - the actor maintains List(Link) as its state
fn handle_message(
  state: List(Link),
  message: Message,
) -> actor.Next(List(Link), Message) {
  case message {
    Add(url, title) -> {
      let new_id = case state {
        [] -> 1
        _ -> list.length(state) + 1
      }
      let new_link = Link(id: new_id, url: url, title: title)
      let new_state = [new_link, ..state]
      actor.continue(new_state)
    }

    GetAll(reply_with) -> {
      process.send(reply_with, state)
      actor.continue(state)
    }

    Shutdown -> {
      actor.stop()
    }
  }
}

// For simplicity, we'll start a fresh actor for each operation
// This is not ideal for production but demonstrates the concept
// In a real app, you'd start the actor once and keep the subject around

// Better API - takes an actor subject as parameter
pub fn add_link_to_store(
  store: process.Subject(Message),
  url: String,
  title: String,
) -> Nil {
  process.send(store, Add(url, title))
}

// Better API - takes an actor subject as parameter  
pub fn get_all_from_store(store: process.Subject(Message)) -> List(Link) {
  let reply_subject = process.new_subject()
  process.send(store, GetAll(reply_subject))

  case process.receive(reply_subject, 100) {
    Ok(links) -> links
    Error(_) -> []
  }
}

// Legacy API for backward compatibility - creates a new actor each time
// Proper Add function that adds to the actor's internal List(Link) state  
pub fn add_link(url: String, title: String) -> Nil {
  case start() {
    Ok(actor_subject) -> {
      process.send(actor_subject, Add(url, title))
      // Give the actor time to process the message
      process.sleep(10)
    }
    Error(_) -> Nil
  }
}

// Legacy API for backward compatibility - creates a new actor each time
// Proper GetAll function that returns the actor's internal List(Link) state
pub fn get_all() -> List(Link) {
  case start() {
    Ok(actor_subject) -> {
      let reply_subject = process.new_subject()
      process.send(actor_subject, GetAll(reply_subject))

      // Wait for response with a timeout
      case process.receive(reply_subject, 100) {
        Ok(links) -> links
        Error(_) -> []
        // Return empty list on timeout/error
      }
    }
    Error(_) -> []
  }
}
