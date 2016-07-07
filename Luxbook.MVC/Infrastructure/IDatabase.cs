namespace Luxbook.MVC.Infrastructure
{
    using System;
    using System.Collections.Generic;
    using System.Data;

    public interface IDatabase
    {
        IDbConnection GetOpenConnection();
        IDbConnection GetConnection();

        void Execute(string storedProcedureName, dynamic parameter = null, IDbTransaction transaction = null,
            int? commandTimeout = null, CommandType commandType = CommandType.StoredProcedure);

        IEnumerable<object> Query(string storedProcedureName, dynamic parameter = null,
            IDbTransaction transaction = null, int? commandTimeout = null);

        IEnumerable<T> Query<T>(string storedProcedureName, dynamic parameter = null,
            IDbTransaction transaction = null, int? commandTimeout = null,
            CommandType commandType = CommandType.StoredProcedure);

        IGridReader QueryMultiple(string storedProcedureName, dynamic parameter = null,
            IDbTransaction transaction = null, int? commandTimeout = null);

        IEnumerable<TReturn> Query<TFirst, TSecond, TReturn>(string storedProcedureName,
            Func<TFirst, TSecond, TReturn> map, dynamic parameter = null, IDbTransaction transaction = null,
            bool buffered = true, string splitOn = "Id", int? commandTimeout = null);

        IEnumerable<TReturn> Query<TFirst, TSecond, TThird, TReturn>(string storedProcedureName,
            Func<TFirst, TSecond, TThird, TReturn> map, dynamic parameter = null, IDbTransaction transaction = null,
            bool buffered = true, string splitOn = "Id", int? commandTimeout = null);

        IEnumerable<TReturn> Query<TFirst, TSecond, TThird, TFourth, TReturn>(
            string storedProcedureName,
            Func<TFirst, TSecond, TThird, TFourth, TReturn> map, dynamic parameter = null,
            IDbTransaction transaction = null,
            bool buffered = true, string splitOn = "Id", int? commandTimeout = null);

        IEnumerable<TReturn> Query<TFirst, TSecond, TThird, TFourth, TFifth, TReturn>(
            string storedProcedureName,
            Func<TFirst, TSecond, TThird, TFourth, TFifth, TReturn> map, dynamic parameter = null,
            IDbTransaction transaction = null, bool buffered = true, string splitOn = "Id", int? commandTimeout = null);

        void ExecuteInTransaction(Action<IDbTransaction> action);
    }
}