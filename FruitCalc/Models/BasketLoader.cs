using Newtonsoft.Json;
using SM.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace SM.FruitCalc.Models
{
    public class BasketLoader : ILoader
    {
        private readonly IBasket _basket;
        private readonly string _filePath;

        public BasketLoader(IBasket basket, string filePath)
        {
            _basket = basket;
            _filePath = filePath;
        }

        public void Load()
        {
            var text = File.ReadAllText(_filePath);

            var data = Deserialize<BasketLoaderData>(text);

            if (data != null) {
                // Work from items in the basket to see if they are defined.
                // (could have 10 definitions, but only 2 types of items in the basket)

                foreach(var item in data.Basket)
                {
                    var dataItem = Find(item.Name, data.Items);

                    if (dataItem != null)
                    {
                        item.Cost = dataItem.Cost;
                    }
                    else
                    {
                        throw new Exception($"Item '{item.Name}' Cost not defined");
                    }

                    // Promotions are optional (don't need an exception)

                    dataItem = Find(item.Name, data.Promotions);

                    if (dataItem != null)
                    {
                        item.Discount = dataItem.Discount;
                    }

                    _basket.Add(item);
                }
            }
        }

        private TType Deserialize<TType>(string jsonData)
        {
            return (TType)Deserialize(new StringReader(jsonData), typeof(TType));
        }

        private object Deserialize(TextReader streamReader, Type type)
        {
            object deserializedObject;

            using (JsonReader reader = new JsonTextReader(streamReader))
            {
                var settings = new JsonSerializerSettings
                {
                    ReferenceLoopHandling = ReferenceLoopHandling.Serialize,
                    PreserveReferencesHandling = PreserveReferencesHandling.All,
                    TypeNameHandling = TypeNameHandling.Auto
                };

                JsonSerializer jsonSerializer = JsonSerializer.Create(settings);
                deserializedObject = jsonSerializer.Deserialize(reader, type);
            }

            return deserializedObject;
        }

        private IItem Find(string name, List<Item> items)
        {
            return items.FirstOrDefault(item => item.Name == name);
        }
    }
}