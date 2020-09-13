using SM.Interfaces;

namespace SM.FruitCalc.Models
{
    public class Calculator : ICalculator
    {
        private readonly IBasket _basket;

        public Calculator(IBasket basket)
        {
            _basket = basket;
        }

        public decimal Calc() {
            decimal result = 0;

            foreach(var item in _basket.Items)
            {
                result += item.Count * item.Cost * (decimal)(item.Discount.HasValue ? item.Discount.Value : 1.0);
            }

            return result;
        }
    }
}