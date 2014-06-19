
//          Copyright Joakim Karlsson & Kim Gräsman 2010-2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

#ifndef DOXTESTLISTENER_H
#define DOXTESTLISTENER_H

#include <algorithm>

namespace igloo {

  class DoxTestListener : public TestListener
  {
    public:
      virtual void TestRunStarting() {}
      virtual void TestRunEnded(const TestResults&) 
      {
        std::cout << std::endl;
      }

      virtual void ContextRunStarting(const ContextBase& context) 
      {
        std::string context_name = context.Name();
        std::replace(context_name.begin(), context_name.end(), '_', ' ');
        std::cout << context_name << ":"<< std::endl;
      }
      virtual void ContextRunEnded(const ContextBase& ) 
      {
        std::cout << std::endl;
      }
      virtual void SpecRunStarting(const ContextBase& context, const std::string& specName) 
      {
        std::string spec_name = specName;
        std::replace(spec_name.begin(), spec_name.end(), '_', ' ');
        std::cout << "  - " << spec_name;      
      }
      virtual void SpecSucceeded(const ContextBase& context, const std::string& specName)
      {
        std::cout << "\t\t Passed" << std::endl;    
      }

      virtual void SpecFailed(const ContextBase& , const std::string& )
      {
        std::cout <<  "\t\t FAILED" << std::endl; 
      }
  };

}
#endif
