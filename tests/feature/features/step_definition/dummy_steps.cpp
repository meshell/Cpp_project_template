#include <string>
#include <vector>
#include <gtest/gtest.h>
#include <cucumber-cpp/defs.hpp>
#include "dummy.h"

using cucumber::ScenarioScope;

namespace {

struct DummyCtx {
  DummyCtx ():
    dummies_(),
    say_hello_result_("")
  {};
  std::vector<CppTemplate::Dummy> dummies_;
  std::string say_hello_result_;
};



GIVEN("^a dummy initialised with \"([^\"]*)\" and \"([^\"]*)\"$") {
  REGEX_PARAM(std::string, hello_string);
  REGEX_PARAM(std::string, world_string);
  CppTemplate::Dummy dummy(hello_string, world_string);
  ScenarioScope<DummyCtx> context;
  context->dummies_.push_back(dummy);
}

GIVEN("^the following dummies:$") {
  TABLE_PARAM(dummy_params);
  ScenarioScope<DummyCtx> context;
  const table_hashes_type& dummies = dummy_params.hashes();

  for (auto iter = dummies.begin(); iter != dummies.end(); ++iter) {
    CppTemplate::Dummy dummy(std::string(iter->at("hello")),
                              std::string(iter->at("world")));
    context->dummies_.push_back(dummy);
  }
}

WHEN("^I command the dummy to say hello$") {
  ScenarioScope<DummyCtx> context;
  context->say_hello_result_ = context->dummies_.front().say_hello();
}


WHEN("^I command the dummy (\\d+) to say hello$") {
  REGEX_PARAM(int, dummy_index);
  ScenarioScope<DummyCtx> context;
  context->say_hello_result_ = context->dummies_.at(dummy_index).say_hello();
}


THEN("^the dummy should say \"([^\"]*)\"$") {
  REGEX_PARAM(std::string, hello_world_string);
  ScenarioScope<DummyCtx> context;
  ASSERT_STREQ(context->say_hello_result_.c_str(), hello_world_string.c_str());
}


}//namespace
