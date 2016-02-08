Note: "BS" stands for BrainStorming.

#Arivale Coding Problem

## Problem description:

    When clients sign up for the Arivale service, they develop a 1:1
    relationship with a wellness coach over the course of a year. These
    coaches help them interpret their personal health data as well as
    make actionable recommendations to improve a client’s overall
    wellness. Clients need to schedule coaching calls on a monthly
    basis. We want to create a web based experience that makes it easy
    for clients to schedule a call. Clients should be able to see their
    coach’s availability and then book hour long coaching slot. Once a
    slot is booked, other clients should not be able to book that slot
    with the same coach.

## Alternatives

    Google Calendar offers an "office hours" appointment mechanism.  It
    doesn't quite do what the problem requires; it's only available to
    other members of the same school or corporate group account.

    

## Solution requirements:

    * Data Store
    * Middle Tier
    * Front-End

## Actors

    * Staff
    * Client

## Tables

    * Table of *Users* (flags "staff," "client," "staff_active," "client_active") [User]
      ** Is there redundant information in those flags?  Table-level
         constraints to prevent "client = false" "client_active = true"
         on the same object, for example?
    * Table of *User/user relationships* [Staff_client_relationship]
      ** staff_user_id (constraint: staff flag must be TRUE, staff_active flag must be TRUE)
      ** client_user_id (constraint: user flag must be TRUE, user_active flag must be TRUE)

    * Table of OfficeHours
      ** When the staff are available:
         *** staff_id
         *** availability: [(timestamp, timestamp)] defining TSRange: Availability

    * Table of *Appointments*
      ** staff_client_relationship_id: ID
      ** reservation: (timestamp, timestamp) defining TSRANGE: Reservation

    * Business rules -> rule values
      ** This could get ugly.  What are the limits?  One rule table per
         rule datatype?  Does Postgres have a union type, and how
         horrible is it to work with?

## Accesses

    * Client
      ** Retrieve: View upcoming appointments
      ** Create: Create a new appointment
      ** Update: Move an existing appointment
      ** Delete: Delete an existing appointment
      ** UNANSWERED QUESTIONS
          *** Recurring appointments?  Set/no set?  How do others handle this?

    REST Documents:
        Appointment request: user, staff, time range
            * payload schema check
                User present and active?
                Staff present and active?
                Relationship present? (note: Never publish staff or relationship ID; user a slug for the customer if possible)
                Time range sane?
                    * Positive length?
                      ** Assertion
                    * Not in the past?
                      ** Assertion (review: "What programmers believe about time")
                      ** No, really: Timezones, Daylight Savings, all that jazz
                    * Legitimate length
                      ** Business Rule
                    * Not too far in the future?
                      ** Business Rule
                      ** Can the business rules be stored in the database?
                      ** If so, you'll need an admin page for them.
                    * Assume attack:
                      ** Handle true fuzz.
                      ** Handle corruptions.
                      ** Handle crap.
                      ** WHITELIST RULES ONLY
                Time range available?
                  ** OFFICE HOURS - for Coach only.
                  ** Database can handle (Postgres has a RANGE operator now)
                  ** Questions about performance, but don't care at this
                     point; just throw more metal at it.
            * Can the INSERT detect user/staff/relationship validity?
            * Can the INSERT deal with (some of) the time issues?
            * What happens on INSERT failure?
                ** How to report?


        Update request:
            * All of the above, plus:
            ** Existing appointment?
            ** Add-then-delete as a transaction, OR Update? Read pros/cons

        Retrieve:
            * Is about permissions and ranges
              ** What the user sees is what the database allows them to see
            * No further back in the past than (Business Rule) weeks
            * If as OPA (i.e. JSON), retrieve a couple weeks in advance,
              with scaling lookahead;   Like you did for Spiral's data
              sources list; the scaling rate can be found in Python List
              implementation, I think.  Or fibonacci with a limiter.
            * 300ms or twiddle.
                ** The above is front-end stuff.
                ** No Bad Ideas.  :-)

        Delete:
           * Appoinment exist?
           * This user?
           
    Other:
        Non-REST issue
            * Progressive Enhancement.  If it doesn't work in Lynx, it
              doesn't work.
                ** Some kind of second-page form for a time range?
            * ARIA/Section 508 coverage?

Unit tests:
    Create: An appointment is a USER wanting a RANGE
        Logged in?
        Good/bad user?
        Good/bad range?
        Good/bad placement?

    Delete:
        Logged in?
        Yours?

    Update:
        Same as create plus:
            Yours?

    Retrieve:
        Only the user ID and the start of the week matter.
        Constraint: No past views.  Not too far in the future
        ** Business Rule again

Secondary considerations: A staff member has a M:1 relationship with
clients, but clients have only a 1:1 with staff.  Encoding that into the
Users table would make sense, only the staff's field would be Null.
While I want to enforce NO-NULL idiom as much as possible, the separate
table for that relationship [1] could be overkill; [2] permits the
development of a M:M relationship where a user could have more than one
coach, time and money permitting, but [2a] (probably) YAGNI.

Backend: Postgres, naturally.  Leveraged as far as humanely possible.
It's been a few years, but I'm genuinely impressed with what it does.

Middle Tier: What's the lightest Python application server there is?
Flask?

Front End: HAML/Less/A script I don't know (Like Clojure, Pure, or Type?
Something fun and different!)

What we don't care about (thus far):

    Logging in.
    Session management.


TODO VirtualEnv
TODO Flask
TODO PsychoPG2
TODO Flask skeleton
TODO Postgres Database
TODO Postgres retrieval example
TODO Postgres range example
TODO Deliver home page
TODO Deliver retreivals
    
---

Quick thoughts:

Craft views or 



    


