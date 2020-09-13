using Microsoft.VisualStudio.TestTools.UnitTesting;
using SM.FruitCalc.Models;

namespace Test.FruitCalc
{
    [TestClass]
    public class BasketTests
    {
        [TestMethod]
        public void AddItem()
        {
            var test = ConstructTestObject();

            test.Add(new Item("Test", 0, null));

            Assert.AreEqual(1, test.Items.Count(), "The item was not added.");
        }

        private IBasket ConstructTestObject() {
            return new Basket();
        }
    }
}
