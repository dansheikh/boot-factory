import java.util.Properties;
import javax.persistence.EntityManagerFactory;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseBuilder;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableJpaRepositories(basePackages = {""},
    entityManagerFactoryRef = "devEntityManagerFactory",
    transactionManagerRef = "devTransactionManager")
@EnableTransactionManagement
@Profile("dev")
public class DevDbConfig {

  final String ENCODING = "UTF-8";

  @Value("${hibernate.dialect}")
  private String hibernateDialect;

  @Value("${hibernate.show_sql}")
  private String hibernateShowSql;

  @Bean(name = "devDataSource", destroyMethod = "shutdown")
  public DataSource dataSource() {
    return new EmbeddedDatabaseBuilder().setName("esi-dev").setType(EmbeddedDatabaseType.H2)
        .setScriptEncoding(ENCODING).ignoreFailedDrops(true).addDefaultScripts().build();
  }

  @Bean(name = "devEntityManagerFactory")
  public LocalContainerEntityManagerFactoryBean entityManagerFactory(
      @Qualifier("devDataSource") DataSource dataSource) {
    final HibernateJpaVendorAdapter jpaVendorAdapter = new HibernateJpaVendorAdapter();
    final LocalContainerEntityManagerFactoryBean factory =
        new LocalContainerEntityManagerFactoryBean();
    final Properties jpaVendorProperties = new Properties();

    jpaVendorProperties.setProperty("hibernate.dialect", hibernateDialect);
    jpaVendorProperties.setProperty("hibernate.show_sql", hibernateShowSql);

    jpaVendorAdapter.setGenerateDdl(false);

    factory.setDataSource(dataSource);
    factory.setJpaVendorAdapter(jpaVendorAdapter);
    factory.setJpaProperties(jpaVendorProperties);
    factory.setPackagesToScan("");
    factory.afterPropertiesSet();

    return factory;
  }

  @Bean(name = "devTransactionManager")
  public JpaTransactionManager transactionManager(
      @Qualifier("devEntityManagerFactory") final EntityManagerFactory entityManagerFactory) {
    final JpaTransactionManager transactionManager = new JpaTransactionManager();
    transactionManager.setEntityManagerFactory(entityManagerFactory);
    return transactionManager;
  }
}
