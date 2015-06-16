#include "CppSpec/CppSpec.h"
#include "dummy_spec.h"

using CppTemplate::Dummy;

int main(int argc, const char* argv[]) {
    DefaultDummySpec defaultDummySpec{};
    EnglishDummySpec englishDummySpec{};

    CppSpec::SpecRunner runner(argc, argv);

    return runner.runSpecifications();
}

