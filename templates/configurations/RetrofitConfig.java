import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import retrofit2.Retrofit;
import retrofit2.converter.jackson.JacksonConverterFactory;

@Configuration
public class RetrofitConfig {

  @Bean(name = "retrofitBuilder")
  public Retrofit.Builder retrofitBuilder() {
    return new Retrofit.Builder().addConverterFactory(JacksonConverterFactory.create());
  }
}
