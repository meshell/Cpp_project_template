#include <string>
#include <igloo/igloo_alt.h>
#include <gmock/gmock.h>
#include "dummy.h"

using CppTemplate::Dummy;
using namespace igloo;


namespace {

Describe (The_newly_created_default_dummy)
{
    It(should_be_speechless)
    {
        Assert::That(dummy.speechless(), Is().EqualTo(true));
    }

    Dummy dummy{};
};

Describe (The_english_dummy)
{
    void SetUp() override
    {
        dummy.reset(new Dummy{"Hello", "World"});
    }

    It(should_not_be_speechless)
    {
        Assert::That(dummy->speechless(), Is().Not().EqualTo(true));
    }

    It(should_speak_english)
    {
        Assert::That(dummy->say_hello(), Is().EqualTo("Hello World"));
    }

    std::unique_ptr<Dummy> dummy{};

};

} //namespace
