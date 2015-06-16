#include <string>
#include <vector>
#include <gtest/gtest.h>
#include <cucumber-cpp/defs.hpp>
#include "dummy.h"

using cucumber::ScenarioScope;

namespace
{

struct DummyCtx
{
    std::vector<CppTemplate::Dummy> dummies{};
    std::string say_hello_result{};
};



GIVEN("^a dummy initialised with \"([^\"]*)\" and \"([^\"]*)\"$")
{
    REGEX_PARAM(std::string, hello_string);
    REGEX_PARAM(std::string, world_string);
    ScenarioScope<DummyCtx> context{};
    context->dummies.emplace_back(CppTemplate::Dummy{hello_string, world_string});
}

GIVEN("^the following dummies:$")
{
    TABLE_PARAM(dummy_params);
    ScenarioScope<DummyCtx> context{};
    const auto& dummies_table = dummy_params.hashes();

    for (const auto& table_row : dummies_table)
    {
        context->dummies.emplace_back(CppTemplate::Dummy{std::string{table_row.at("hello")},
                                                         std::string{table_row.at("world")}});
    }
}

WHEN("^I command the dummy to say hello$")
{
    ScenarioScope<DummyCtx> context{};
    context->say_hello_result = context->dummies.front().say_hello();
}


WHEN("^I command the dummy (\\d+) to say hello$")
{
    REGEX_PARAM(size_t, dummy_index);
    ScenarioScope<DummyCtx> context{};
    context->say_hello_result = context->dummies.at(dummy_index).say_hello();
}


THEN("^the dummy should say \"([^\"]*)\"$")
{
    REGEX_PARAM(std::string, hello_world_string);
    ScenarioScope<DummyCtx> context{};
    ASSERT_STREQ(context->say_hello_result.c_str(), hello_world_string.c_str());
}


}//namespace
