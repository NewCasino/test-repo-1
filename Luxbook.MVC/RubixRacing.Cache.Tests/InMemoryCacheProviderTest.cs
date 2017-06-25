namespace RubixRacing.Cache.Tests
{
    using System;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using NUnit.Framework;

    [TestFixture]
    public class InMemoryCacheProviderTest
    {
        [SetUp]
        public void Setup()
        {
            _cacheItems = new ConcurrentDictionary<string, InMemoryCacheItem>();
            _provider = new InMemoryCacheProvider(_cacheItems);
        }

        private InMemoryCacheProvider _provider;
        private ConcurrentDictionary<string, InMemoryCacheItem> _cacheItems;

        [Test]
        public void GetItem_NoRetrieve_ShouldGetCachedItem()
        {
            var cachedItem = 10;
            int resultItem;
            var key = "foo";
            _cacheItems[key] = new InMemoryCacheItem {Item = cachedItem};

            var result = _provider.GetItem(key, out resultItem);

            Assert.That(result, Is.True);
            Assert.That(resultItem, Is.EqualTo(cachedItem));
        }

        [Test]
        public void GetItem_NoRetrieve_ShouldGetCachedItemIfNotExpired()
        {
            var cachedItem = 10;
            int resultItem;
            var key = "foo";
            _cacheItems[key] = new InMemoryCacheItem {Item = cachedItem, ExpiryTime = DateTime.Now.AddHours(1)};

            var result = _provider.GetItem(key, out resultItem);

            Assert.That(result, Is.True);
            Assert.That(resultItem, Is.EqualTo(cachedItem));
        }

        [Test]
        public void GetItem_NoRetrieve_ShouldNotGetCachedItem()
        {
            int resultItem;
            var key = "foo";

            var result = _provider.GetItem(key, out resultItem);

            Assert.That(result, Is.False);
        }

        [Test]
        public void GetItem_NoRetrieve_ShouldNotGetCachedItemIfExpired()
        {
            var cachedItem = 10;
            int resultItem;
            var key = "foo";
            _cacheItems[key] = new InMemoryCacheItem {Item = cachedItem, ExpiryTime = DateTime.Now.AddHours(-1)};

            var result = _provider.GetItem(key, out resultItem);

            Assert.That(result, Is.False);
        }

        [Test]
        public void GetItem_NoRetrieve_ShouldTouchCachedItem()
        {
            var cachedItem = 10;
            int resultItem;
            var key = "foo";
            _cacheItems[key] = new InMemoryCacheItem
            {
                Item = cachedItem,
                ExpiryTime = DateTime.Now.AddHours(1),
                CachePolicy = new CachePolicy {SlidingWindowExpiration = TimeSpan.FromDays(1)}
            };

            var result = _provider.GetItem(key, out resultItem);

            Assert.That(_cacheItems[key].ExpiryTime, Is.GreaterThan(DateTime.Now.AddHours(1)));
        }

        [Test]
        public void GetItem_ShouldGetCachedItem()
        {
            var fresh = false;
            var cachedItem = 10;
            var item = 5;
            var key = "foo";
            _cacheItems[key] = new InMemoryCacheItem {Item = cachedItem};

            var result = _provider.GetItem(() =>
            {
                fresh = true;
                return item;
            }, null, key);


            Assert.That(result, Is.EqualTo(cachedItem));
            Assert.That(fresh, Is.False);
        }

        [Test]
        public void GetItem_ShouldGetFreshItem()
        {
            var fresh = false;
            var item = 5;
            var key = "foo";

            var result = _provider.GetItem(() =>
            {
                fresh = true;
                return item;
            }, null, key);


            Assert.That(result, Is.EqualTo(item));
            Assert.That(_cacheItems[key].ExpiryTime.HasValue, Is.False);
            Assert.That(fresh, Is.True);
        }

        [Test]
        public void GetItem_ShouldSetAbsoluteExpiry()
        {
            var fresh = false;
            var item = 5;
            var key = "foo";

            var result = _provider.GetItem(() =>
            {
                fresh = true;
                return item;
            }, CachePolicy.FifteenMinuteAbsoluteExpirationPolicy(), key);


            Assert.That(_cacheItems[key].ExpiryTime, Is.GreaterThan(DateTime.Now.AddMinutes(14)));
        }

        [Test]
        public void RemoveItem_ShouldRemoveItemFromCache()
        {
            var cachedItem = 10;
            var key = "foo";
            _cacheItems[key] = new InMemoryCacheItem {Item = cachedItem, ExpiryTime = DateTime.Now.AddHours(-1)};
            _cacheItems["bar"] = new InMemoryCacheItem {Item = cachedItem, ExpiryTime = DateTime.Now.AddHours(-1)};

            _provider.RemoveItem(key);

            Assert.That(_cacheItems.Count, Is.EqualTo(1));
            Assert.That(_cacheItems.ContainsKey(key), Is.False);
        }
    }
}