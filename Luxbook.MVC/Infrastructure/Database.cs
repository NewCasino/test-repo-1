namespace Luxbook.MVC.Infrastructure
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.Diagnostics.CodeAnalysis;
    using Dapper;
    using NLog;

    /// <summary>
    ///     Wrapper around dapper for unit testing and to provide helper methods to execute SPs quickly
    ///     Also provides easier transaction support as well as testable gridreader
    /// </summary>
    [SuppressMessage("Microsoft.Design", "CA1004:GenericMethodsShouldProvideTypeParameter",
        Justification =
            "Function doesn't require any arguments and it is a wrapper and should stay as close as the original methods"
        )]
    public class Database : IDatabase
    {
        private readonly IConfigurationManager _configurationManager;
        private readonly ILogger _log;

        public Database(IConfigurationManager configurationManager)
        {
            _configurationManager = configurationManager;
            _log = LogManager.GetCurrentClassLogger();
        }

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "It is not a property of the class")]
        public virtual IDbConnection GetOpenConnection()
        {
            var connection = GetConnection();
            connection.Open();
            return connection;
        }

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "It is not a property of the class")]
        public virtual IDbConnection GetConnection()
        {
            return
                new SqlConnection(
                    _configurationManager.GetConnectionString());
        }

        public void Execute(string storedProcedureName, dynamic parameter = null, IDbTransaction transaction = null,
            int? commandTimeout = null, CommandType commandType = CommandType.StoredProcedure)
        {
            if (_log.IsDebugEnabled)
            {
                _log.Debug("Executing sp {0} with parameters {1}", storedProcedureName, parameter?.ToString());
            }
            if (transaction != null)
            {
                SqlMapper.Execute(transaction.Connection, storedProcedureName, parameter, transaction,
                    commandTimeout,
                    commandType);
            }

            using (var conn = GetOpenConnection())
            {
                try
                {
                    SqlMapper.Execute(conn, storedProcedureName, parameter, transaction, commandTimeout,
                        commandType);
                }
                catch (Exception ex)
                {
                    _log.Error(string.Format("Error running stored proc {0}", storedProcedureName), ex);
                    throw;
                }
            }
        }

        public IEnumerable<dynamic> Query(string storedProcedureName, dynamic parameter = null,
            IDbTransaction transaction = null, int? commandTimeout = null)
        {
            if (transaction != null)
            {
                return
                    SqlMapper.Query<dynamic>(transaction.Connection, sql: storedProcedureName, param: parameter,
                        transaction: transaction, commandTimeout: commandTimeout,
                        commandType: CommandType.StoredProcedure);
            }

            using (var conn = GetOpenConnection())
            {
                return SqlMapper.Query<dynamic>(conn, sql: storedProcedureName, param: parameter,
                    transaction: transaction, commandTimeout: commandTimeout, commandType: CommandType.StoredProcedure);
            }
        }

        [SuppressMessage("Microsoft.Design", "CA1004:GenericMethodsShouldProvideTypeParameter",
            Justification = "wrapper methods")]
        public IEnumerable<T> Query<T>(string storedProcedureName, dynamic parameter = null,
            IDbTransaction transaction = null, int? commandTimeout = null, CommandType commandType = CommandType.StoredProcedure)
        {
            if (_log.IsDebugEnabled)
            {
                _log.Debug("Executing sp {0} with parameters {1}", storedProcedureName, parameter ?? "");
            }
            if (transaction != null)
            {
                try
                {
                    return
                        SqlMapper.Query<T>(transaction.Connection, storedProcedureName, parameter, transaction, true,
                            commandTimeout,
                           commandType);
                }
                catch (Exception ex)
                {
                    _log.Error(string.Format("Error executing sp {0}", storedProcedureName), ex);
                    throw;
                }
            }

            using (var conn = GetOpenConnection())
            {
                return
                    SqlMapper.Query<T>(conn, storedProcedureName, parameter, transaction, true, commandTimeout,
                        commandType);
            }
        }

        public IGridReader QueryMultiple(string storedProcedureName, dynamic parameter = null,
            IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var conn = transaction == null ? GetOpenConnection() : transaction.Connection;

            return
                new GridReader(
                    SqlMapper.QueryMultiple(conn, storedProcedureName, parameter, transaction, commandTimeout,
                        CommandType.StoredProcedure), conn);
        }

        public IEnumerable<TReturn> Query<TFirst, TSecond, TReturn>(string storedProcedureName,
            Func<TFirst, TSecond, TReturn> map, dynamic parameter = null, IDbTransaction transaction = null,
            bool buffered = true, string splitOn = "Id", int? commandTimeout = null)
        {
            if (transaction != null)
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TReturn>(transaction.Connection, storedProcedureName, map,
                        parameter, transaction,
                        buffered, splitOn, commandTimeout,
                        CommandType.StoredProcedure);
            }

            using (var conn = GetOpenConnection())
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TReturn>(conn, storedProcedureName, map, parameter,
                        transaction,
                        buffered, splitOn, commandTimeout,
                        CommandType.StoredProcedure);
            }
        }

        public IEnumerable<TReturn> Query<TFirst, TSecond, TThird, TReturn>(string storedProcedureName,
            Func<TFirst, TSecond, TThird, TReturn> map, dynamic parameter = null, IDbTransaction transaction = null,
            bool buffered = true, string splitOn = "Id", int? commandTimeout = null)
        {
            if (transaction != null)
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TThird, TReturn>(transaction.Connection, storedProcedureName,
                        map, parameter,
                        transaction,
                        buffered, splitOn, commandTimeout,
                        CommandType.StoredProcedure);
            }

            using (var conn = GetOpenConnection())
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TThird, TReturn>(conn, storedProcedureName, map, parameter,
                        transaction,
                        buffered, splitOn, commandTimeout,
                        CommandType.StoredProcedure);
            }
        }

        public IEnumerable<TReturn> Query<TFirst, TSecond, TThird, TFourth, TReturn>(
            string storedProcedureName,
            Func<TFirst, TSecond, TThird, TFourth, TReturn> map, dynamic parameter = null,
            IDbTransaction transaction = null,
            bool buffered = true, string splitOn = "Id", int? commandTimeout = null)
        {
            if (transaction != null)
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TThird, TFourth, TReturn>(transaction.Connection,
                        storedProcedureName, map,
                        parameter, transaction, buffered,
                        splitOn, commandTimeout,
                        CommandType.StoredProcedure);
            }

            using (var conn = GetOpenConnection())
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TThird, TFourth, TReturn>(conn, storedProcedureName, map,
                        parameter, transaction, buffered,
                        splitOn, commandTimeout,
                        CommandType.StoredProcedure);
            }
        }

        public IEnumerable<TReturn> Query<TFirst, TSecond, TThird, TFourth, TFifth, TReturn>(
            string storedProcedureName,
            Func<TFirst, TSecond, TThird, TFourth, TFifth, TReturn> map, dynamic parameter = null,
            IDbTransaction transaction = null, bool buffered = true, string splitOn = "Id", int? commandTimeout = null)
        {
            if (transaction != null)
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TThird, TFourth, TFifth, TReturn>(transaction.Connection,
                        storedProcedureName,
                        map, parameter, transaction,
                        buffered, splitOn,
                        commandTimeout,
                        CommandType.
                            StoredProcedure);
            }

            using (var conn = GetOpenConnection())
            {
                return
                    SqlMapper.Query<TFirst, TSecond, TThird, TFourth, TFifth, TReturn>(conn,
                        storedProcedureName,
                        map, parameter, transaction,
                        buffered, splitOn,
                        commandTimeout,
                        CommandType.
                            StoredProcedure);
            }
        }

        public void ExecuteInTransaction(Action<IDbTransaction> action)
        {
            var dbTransaction = BeginTrans();
            var connection = dbTransaction.Connection;
            try
            {
                action(dbTransaction);
                dbTransaction.Commit();
            }
            catch (Exception)
            {
                dbTransaction.Rollback();
                throw;
            }
            finally
            {
                connection.Close();
            }
        }

        private IDbTransaction BeginTrans()
        {
            return GetOpenConnection().BeginTransaction();
        }
    }
}