#include <string>
#include <igloo/igloo.h>
#include "dummy.h"

using CppTemplate::Dummy;
using namespace igloo;


namespace {

Context (A_newly_created_default_dummy)
{
    Spec(should_be_speechless)
    {
        Assert::That(dummy.speechless(), Is().EqualTo(true));
    }

    Dummy dummy{};
};

Context (A_english_dummy)
{
    void SetUp()
    {
        dummy.reset(new Dummy{"Hello", "World"});
    }

    Spec(should_not_be_speechless)
    {
        Assert::That(dummy->speechless(), Is().Not().EqualTo(true));
    }

    Spec(should_speak_english)
    {
        Assert::That(dummy->say_hello(), Is().EqualTo("Hello World"));
    }

    std::unique_ptr<Dummy> dummy{};

};

} //namespace
