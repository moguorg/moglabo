package test.org.geese.ci.classifier;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;

@RunWith(Suite.class)
@Suite.SuiteClasses({
	TestConfigLoading.class,
	TestDocumentFiltering.class,
})
public class AllCITests{
}