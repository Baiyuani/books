---
tags:
  - ci/cd
  - gradle
  - java
---
## gradle plugin 设置插件仓库

用于解决默认仓库https://plugins.gradle.org/m2/国内访问的网络问题


修改项目根目录的`settings.gradle`

```
pluginManagement {
  repositories {
    maven {
      url 'https://maven.aliyun.com/repository/public/'
    }
    maven {
      url 'https://maven.aliyun.com/repository/spring/'
    }    
    maven {
      url 'https://maven.aliyun.com/repository/spring-plugin/'
    }
    maven {
      url 'https://maven.aliyun.com/repository/central/'
    }
    maven {
      url 'https://maven.aliyun.com/repository/google/'
    }
    maven {
      url 'https://maven.aliyun.com/repository/jcenter/'
    }    
    maven {
      url 'https://maven.aliyun.com/repository/releases/'
    }    
    maven {
      url 'https://maven.aliyun.com/repository/gradle-plugin/'
    } 
    maven {
      url 'https://maven.aliyun.com/repository/grails-core/'
    }
           
    mavenLocal()
    mavenCentral()
  }
}

```