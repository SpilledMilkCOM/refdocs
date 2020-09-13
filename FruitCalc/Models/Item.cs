using SM.Interfaces;

namespace SM.FruitCalc.Models
{
    public class Item : IValidItem
    {
        public Item(string name, decimal cost, int count, float? discount)
        {
            Name = name;
            Cost = cost;
            Count = count;
            Discount = discount;
        }

        public decimal Cost { get; set; }

        public int Count { get; set; }

        public float? Discount { get; set; }

        public string Name { get; }

        public bool IsValid()
        {
            var result = true;

            result &= !string.IsNullOrEmpty(Name);
            result &= Cost >= 0;
            result &= Count >= 0;

            return result;
        }
    }
}
