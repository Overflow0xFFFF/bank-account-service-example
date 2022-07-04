# bank-service

This is an example Flask application for a bank.
It provides a simplistic REST API for performing basic functions,
such as creating an account, checking a balance,
and performing deposits and withdrawals.

## Approach

When asked to implement this exercise,
Flask seemed like the natural choice.
Django is a fine framework,
but seemed a bit heavy on top of my lack of Django experience.
It felt too risky to attempt using a framework with which I had little playtime.

I usually start with a Makefile for my repositories because I forget commands
pretty easily after a decade in the industry.
All of my makefiles have a `help` target and a useful description.
This allows me to be kind to my future self.

I started development with Flask and PDM, as opposed to Poetry or Pipenv.
In retrospect, I feel that this was a mistake.
PDM is _very_ fast, but there aren't as many resources on using it with
distroless containers.
While PDM was excellent from the development perspective,
I ended up spending a lot of valuable time waiting for containers to build.
This was no fault of PDM's,
but more how I architected my container to begin with.

When I started, I iterated first with Sqlite.
It's an easy-to-use database, and I wanted to test the business logic as
rapidly as possible.
This was smart!
But it ended up being a headache when I needed to transition away from it.
My target platform was PostgreSQL.
Now that I'm a bit wiser (and have a reference project!),
I would have started with pure docker-compose for the development environment.

The implementation of the app itself is not something I'm proud of.
I'm a big fan of Clean Architecture and Hexagonal Architecture,
but I spent too much time initially fighting with Flask.
I find Clean Architecture to be really extensible (though a bit verbose)
and testable.
Instead, I opted for the middle ground: Flask blueprints.
Blueprints allowed me to leave room for scalability in the future,
perhaps to toggle bits and pieces of the application on and off at will.
This can be a bit dangerous, because I didn't need it just yet,
but leaving a path or a signpost to future growth has yet to bite me.

## Getting Started

This repository uses a Makefile as its primary orchestrator.
These dependencies are required for deployment:

- docker
- docker-compose
- python3
- pdm (obtainable through pip)

These dependencies are optional, but you may find them useful:
- httpie

Once you have obtained the dependencies above,
run the following command to set up your development environment:

    make init

After that, you are able to hack away at the source code!
If you're looking to deploy and test the project,
run the following command:

    make docker/start

## Recognition / Thanks

I ended up leveraging a lot of initial structure from this project:

https://github.com/cookiecutter-flask/cookiecutter-flask

Not everything in the repository is how I usually think about things,
so some modifications were made.
But it helped get me on the right track!


