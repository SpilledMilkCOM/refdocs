using SM.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;

namespace SM.FruitCalc.Models
{
    public class Basket : IBasket, IValid
    {
        private readonly IList<IValidItem> _items;

        public Basket()
        {
            _items = new List<IValidItem>();
        }

        public void Add(IValidItem item)
        {
            if (! item.IsValid()) {
                throw new Exception("Item is invalid.");
            }

            if (_items.Any(exitingItem => exitingItem.Name == item.Name ))
            {
                throw new Exception($"Item already exists '{item.Name}'.");
            }

            _items.Add(item);
        }

        public void Clear()
        {
            _items.Clear();
        }

        public bool IsValid()
        {
            var result = true;

            foreach (var item in _items)
            {
                result &= item.IsValid();
            }

            return result;
        }

        public IEnumerable<IValidItem> Items => _items;
    }
}