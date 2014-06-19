#include <igloo/igloo.h>

#include "doxtestlistener.h"
#include <memory>

using igloo::TestResultsOutput;

int main(int argc, const char* argv[])
{

  choices::options opt = choices::parse_cmd(argc, argv);

  if(choices::has_option("version", opt))
  {
    std::cout << IGLOO_VERSION << std::endl;
    return 0;
  }

  if(choices::has_option("help", opt))
  {
    std::cout << "Usage: <igloo-executable> [--version] [--output=color|vs|xunit]" << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  --version:\tPrint version of igloo and exit." << std::endl;
    std::cout << "  --output:\tFormat output of test results." << std::endl;
    std::cout << "\t\t--output=color:\tColored output" << std::endl;
    std::cout << "\t\t--output=vs:\tVisual studio friendly output." << std::endl;
    std::cout << "\t\t--output=xunit:\tXUnit formatted output." << std::endl;
    std::cout << "\t\t--output=default:\tDefault output format." << std::endl;
    return 0;
  }

  std::unique_ptr<TestResultsOutput> output;
  bool use_default = false;
  if(choices::has_option("output", opt))
  {
    std::string val = choices::option_value("output", opt);
    if(val == "vs")
    {
      output = std::unique_ptr<TestResultsOutput>(new igloo::VisualStudioResultsOutput());
    }
    else if(val == "color")
    {
      output = std::unique_ptr<TestResultsOutput>(new igloo::ColoredConsoleTestResultsOutput());
    }
    else if(val == "xunit")
    {
      output = std::unique_ptr<TestResultsOutput>(new igloo::XUnitResultsOutput());
    }
    else if(val == "default")
    {
      output = std::unique_ptr<TestResultsOutput>(new igloo::DefaultTestResultsOutput());
      use_default = true;
    }
    else
    {
      std::cerr << "Unknown output: " << choices::option_value("output", opt) << std::endl;
      return 1;
    }
  }
  else
  {
    output = std::unique_ptr<TestResultsOutput>(new igloo::DefaultTestResultsOutput());
    use_default = true;
  }

  igloo::TestRunner runner(*(output.get()));

  igloo::DoxTestListener dox_listener;
  if (use_default) 
  {
    runner.AddListener(&dox_listener);
  }

  return runner.Run();
}
