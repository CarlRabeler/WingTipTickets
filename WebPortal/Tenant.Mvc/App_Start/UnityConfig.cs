using System;
using System.Collections.Specialized;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Mvc;
using Microsoft.AspNet.Identity;
using Microsoft.Practices.Unity;
using Microsoft.ServiceBus.Messaging;
using Tenant.Mvc.Core.Models;
using Unity.Mvc5;

using TenantRepositories = Tenant.Mvc.Core.Repositories.Tenant;
using TenantInterfaces = Tenant.Mvc.Core.Interfaces.Tenant;

using RecommendationRepositories = Tenant.Mvc.Core.Repositories.Recommendations;
using RecommendationInterfaces = Tenant.Mvc.Core.Interfaces.Recommendations;

namespace Tenant.Mvc
{
    public static class UnityConfig
    {
        #region - Public Methods -

        public static void RegisterComponents()
        {
            var container = new UnityContainer();
            var settings = WebConfigurationManager.AppSettings;

            RegisterSqlConnection(container, settings);
            RegisterTenantComponents(container);
            RegisterRecommendationComponents(container);
            RegisterEventHubComponents(settings, container);

            DependencyResolver.SetResolver(new UnityDependencyResolver(container));
        }

        #endregion

        #region - Private Methods -

        private static void RegisterSqlConnection(UnityContainer container, NameValueCollection settings)
        {
            // Register sql connection
            container.RegisterInstance<Func<SqlConnection>>(() =>
            {
                var builder = new SqlConnectionStringBuilder
                {
                    DataSource = settings["SqlServer"], 
                    InitialCatalog = settings["SqlDB"], 
                    UserID = settings["SqlUserID"], 
                    Password = settings["SqlPassword"]
                };

                return new SqlConnection(builder.ToString());
            });
        }

        private static void RegisterTenantComponents(UnityContainer container)
        {
            // Register tenant components
            container.RegisterType<TenantInterfaces.IConcertRepository, TenantRepositories.ConcertRepository>();
            container.RegisterType<TenantInterfaces.ICustomerRepository, TenantRepositories.CustomerRepository>();
            container.RegisterType<TenantInterfaces.IArtistRepository, TenantRepositories.ArtistRepository>();
            container.RegisterType<TenantInterfaces.ICityRepository, TenantRepositories.CityRepository>();
            container.RegisterType<TenantInterfaces.IVenueRepository, TenantRepositories.VenueRepository>();
            container.RegisterType<TenantInterfaces.ITicketRepository, TenantRepositories.TicketRepository>();
            container.RegisterType<TenantInterfaces.IVenueMetaDataRepository, TenantRepositories.VenueMetaDataRepository>();
        }

        private static void RegisterRecommendationComponents(UnityContainer container)
        {
            // Register recommendation components
            container.RegisterType<RecommendationInterfaces.ICustomerRepository, RecommendationRepositories.CustomerRepository>();
            container.RegisterType<RecommendationInterfaces.IProductsRepository, RecommendationRepositories.ProductsRepository>();
            container.RegisterType<RecommendationInterfaces.IPromotionsRepository, RecommendationRepositories.PromotionsRepository>();
            container.RegisterType<RecommendationInterfaces.ITelemetryRepository, RecommendationRepositories.TelemetryRepository>();
            container.RegisterType<IUserStore<CustomerRec>, RecommendationRepositories.CustomerRepository>();
        }

        private static void RegisterEventHubComponents(NameValueCollection settings, UnityContainer container)
        {
            // Register event hub components
            var serviceBusConnectionString = settings["Microsoft.ServiceBus.ConnectionString"];
            var clickEventHubName = settings["clickEvents"];
            var purchaseEventHubName = settings["purchaseEvents"];

            container.RegisterInstance(
                new EventHubs(EventHubClient.CreateFromConnectionString(serviceBusConnectionString, clickEventHubName), 
                    EventHubClient.CreateFromConnectionString(serviceBusConnectionString, purchaseEventHubName)));
        }

        #endregion
    }
}