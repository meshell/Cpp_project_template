#include "dummy_spec.h"

using CppTemplate::Dummy;

void DefaultDummySpec::isSpeechless ()
{
  specify(should.be().speechless());
}

Dummy* EnglishDummySpec::createContext() {
    Dummy* dummy = new Dummy("Hello", "World");
    return dummy;
}


void EnglishDummySpec::is_not_speechless ()
{
  specify(not should.be().speechless());
}

void EnglishDummySpec::speaks_english ()
{
  specify(context().say_hello(), should.equal("Hello World"));
}
