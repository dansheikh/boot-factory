import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@EnableSwagger2
@Profile({"dev", "test"})
public class SwaggerConfig {

  private ApiInfo info() {
    ApiInfo apiInfo = new ApiInfoBuilder().title("TODO")
      .description("TODO").version("TODO").build();

  @Bean(name = "apiDocket")
  public Docket apiDocket() {
    return new Docket(DocumentationType.SWAGGER_2).useDefaultResponseMessages(false).select()
        .apis(RequestHandlerSelectors.any())
        .paths(PathSelectors.any()).build().apiInfo(info());
  }
}
