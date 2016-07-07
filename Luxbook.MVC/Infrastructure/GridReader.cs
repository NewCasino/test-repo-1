namespace Luxbook.MVC.Infrastructure
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Diagnostics.CodeAnalysis;
    using Dapper;

    /// <summary>
    ///     Wrapper class around gridreader to make unit testing easier
    /// </summary>
    public class GridReader : IGridReader
    {
        private IDbConnection _connection;
        private SqlMapper.GridReader _innerGridReader;


        public GridReader(SqlMapper.GridReader reader, IDbConnection connection)
        {
            _innerGridReader = reader;
            _connection = connection;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        public IEnumerable<TReturn> Read<TFirst, TSecond, TThird, TFourth, TFifth, TSixth, TSeventh, TReturn>(
            Func<TFirst, TSecond, TThird, TFourth, TFifth, TSixth, TSeventh, TReturn> func, string splitOn = "id")
        {
            return _innerGridReader.Read(func, splitOn);
        }

        [SuppressMessage("Microsoft.Design", "CA1004:GenericMethodsShouldProvideTypeParameter",
            Justification = "This is a wrapper method")]
        public IEnumerable<T> Read<T>()
        {
            return _innerGridReader.Read<T>();
        }

        public IEnumerable<TReturn> Read<TFirst, TSecond, TThird, TFourth, TReturn>(
            Func<TFirst, TSecond, TThird, TFourth, TReturn> func, string splitOn = "id")
        {
            return _innerGridReader.Read(func, splitOn);
        }

        public IEnumerable<TReturn> Read<TFirst, TSecond, TReturn>(Func<TFirst, TSecond, TReturn> func,
            string splitOn = "id")
        {
            return _innerGridReader.Read(func, splitOn);
        }

        public IEnumerable<TReturn> Read<TFirst, TSecond, TThird, TReturn>(Func<TFirst, TSecond, TThird, TReturn> func,
            string splitOn = "id")
        {
            return _innerGridReader.Read(func, splitOn);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                _innerGridReader.Dispose();
                _connection.Dispose();
                _innerGridReader = null;
                _connection = null;
            }
        }
    }
}