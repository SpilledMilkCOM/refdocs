using SM.FruitCalc.Models;

using System;
using System.Linq;

namespace SM.FruitCalc
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1)
            {
                Console.WriteLine("Usage FruitCalc:\nFruitCalc <path to data file>");
            }
            else
            {
                var basket = new Basket();
                var loader = new BasketLoader(basket, args[0]);

                loader.Load();

                var calculator = new Calculator(basket);

                if (basket.Items.Count() > 0)
                {
                    Console.WriteLine("Items in basket:");

                    foreach (var item in basket.Items)
                    {
                        var discount = (item.Discount.HasValue ? $" (discount {item.Discount.Value * 100}%)" : string.Empty);

                        Console.WriteLine($"{item.Count} {item.Name} @ ${item.Cost} each{discount}");
                    }
                }
                else
                {
                    Console.WriteLine("Nothing in the basket.");
                }

                Console.WriteLine($"\nTotal price = ${calculator.Calc()}");
            }
        }
    }
}