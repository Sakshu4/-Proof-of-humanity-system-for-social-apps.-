module ProofOfHumanity::ProofSystem {

    use aptos_framework::signer;
    use aptos_framework::event::{self, Event};

    /// Struct representing a user registration.
    struct Registration has store, key {
        verified: bool,    // Indicates if the user has been verified
    }

    /// Event emitted when a user is successfully registered.
    struct RegistrationEvent has drop {
        user: address,
    }

    /// Event handle for registration events.
    struct RegistrationEvents has store {
        handle: Event<RegistrationEvent>,
    }

    /// Initialize the event handle for the registration.
    public fun init_registration_events(owner: &signer) {
        if (!exists<RegistrationEvents>(signer::address_of(owner))) {
            let event_handle = RegistrationEvents {
                handle: event::new<RegistrationEvent>(owner),
            };
            move_to(owner, event_handle);
        }
    }

    /// Function to register a user.
    public fun register_user(user: &signer) {
        let user_address = signer::address_of(user);
        assert(!exists<Registration>(user_address), 1, "User already registered");

        let registration = Registration {
            verified: false,
        };
        move_to(user, registration);

        // Emit registration event
        let event_handle = borrow_global_mut<RegistrationEvents>(user_address);
        event::emit_event(&mut event_handle.handle, RegistrationEvent { user: user_address });
    }

    /// Function to verify a user.
    public fun verify_user(verifier: &signer, user_address: address) acquires Registration {
        let registration = borrow_global_mut<Registration>(user_address);
        registration.verified = true;
    }
}
