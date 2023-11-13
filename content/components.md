### Providers提供者

`Providers` 是 `Nest` 中一个基本的概念。 `Nest` 中许多基本的 `classes` 都可以被视为一个 `provider` – services(服务)， repositories(存储库), factories(工厂), helpers(帮助工具), 等等。一个 `provider` 的主要思想是，它可以被作为依赖 **注入**；这意味着对象之间可以创造各种关系，而 "连接" 这些对象的功能很大程度上可以委托给 `Nest runtime system(Nest运行时系统)`。

<figure><img src="/assets/Components_1.png" /></figure>

在之前的章节中，我们构建了一个简单的 `CatsController`。 `Controllers` 需要处理 HTTP 请求，并委托更加复杂的任务给 **providers**。 `Providers` 是普通的 `JavaScript classes` 以至于可以在 [module](/modules) 中被声明为 `providers`。

> info **提示** 因为 `Nest` 以一种面向对象的方式使设计和管理依赖成为可能，我们强烈推荐遵守 [SOLID](https://en.wikipedia.org/wiki/SOLID) 原则.

> 软件设计中的类责任、扩展和接口使用原则
> 1. 单一职责原则:
>   + 每个类应该只有一个职责。
>   + 这一原则使类更易于维护和理解。
> 2. 开闭原则:
>    + 软件实体应该对扩展开放，但对修改关闭。
>    + 该原则鼓励使用抽象和接口来实现灵活性。
> 3. 里氏替换原则:
>   + 使用基类指针或引用的函数应该能够使用派生类的对象。
>   + 这一原则支持契约设计的理念。
> 4. 接口隔离原则:
>    + 不应强迫客户端依赖他们不使用的接口。
>    + 这一原则促进了为不同的客户端创建特定的接口。

#### 服务

让我们从创建一个简单的 `CatsService` 开始。 这个服务负责数据的存储和检索，并且被设计供 `CatsController` 使用，所以被定义为一个 `provider` 是一个好的方式。

```typescript
@@filename(cats.service)
import { Injectable } from '@nestjs/common';
import { Cat } from './interfaces/cat.interface';

@Injectable()
export class CatsService {
  private readonly cats: Cat[] = [];

  create(cat: Cat) {
    this.cats.push(cat);
  }

  findAll(): Cat[] {
    return this.cats;
  }
}
@@switch
import { Injectable } from '@nestjs/common';

@Injectable()
export class CatsService {
  constructor() {
    this.cats = [];
  }

  create(cat) {
    this.cats.push(cat);
  }

  findAll() {
    return this.cats;
  }
}
```

> info **提示** 为了使用 `Nest CLI` 创建一个 `service`，只需执行 `$ nest g service cats` 这条命令。

我们的 `CatsService` 是一个基本的类并带有一个属性和两个方法。唯一的新特性，是使用到了 `@Injectable()` 这个装饰器。`@Injectable()` 这个装饰器附加了元数据，它声明 `CatsService` 是一个由 `Nest` [IoC](https://en.wikipedia.org/wiki/Inversion_of_control) 管理的容器。 顺便一提，这个例子也使用到了 `Cat` 接口，这可能看起来像这样:

```typescript
@@filename(interfaces/cat.interface)
export interface Cat {
  name: string;
  age: number;
  breed: string;
}
```

现在我们拥有一个 `service class` 用来找回猫咪，让我们在 `CatsController` 内部使用它:

```typescript
@@filename(cats.controller)
import { Controller, Get, Post, Body } from '@nestjs/common';
import { CreateCatDto } from './dto/create-cat.dto';
import { CatsService } from './cats.service';
import { Cat } from './interfaces/cat.interface';

@Controller('cats')
export class CatsController {
  constructor(private catsService: CatsService) {}

  @Post()
  async create(@Body() createCatDto: CreateCatDto) {
    this.catsService.create(createCatDto);
  }

  @Get()
  async findAll(): Promise<Cat[]> {
    return this.catsService.findAll();
  }
}
@@switch
import { Controller, Get, Post, Body, Bind, Dependencies } from '@nestjs/common';
import { CatsService } from './cats.service';

@Controller('cats')
@Dependencies(CatsService)
export class CatsController {
  constructor(catsService) {
    this.catsService = catsService;
  }

  @Post()
  @Bind(Body())
  async create(createCatDto) {
    this.catsService.create(createCatDto);
  }

  @Get()
  async findAll() {
    return this.catsService.findAll();
  }
}
```

`CatsService` 这个 `service` 被 **注入** 通过类的构造函数。注意到使用到了 `private` 语法。 这种简写允许我们在同一位置立即地声明和初始化 `catsService` 成员。

#### 依赖注入

`Nest` 是围绕通常被称为 **Dependency injection(译为:依赖注入)** 的强大设计模式构建的。我们建议您在 [Angular](https://angular.io/guide/dependency-injection) 官方文档阅读一篇关于这个概念的好文章。

在 `Nest`中， 感谢 `TypeScript` 的能力，管理依赖变得很容易，因为它们仅按类型解析。在下面的例子中， `Nest` 将会通过创建并返回 `CatsService` 的实例(或者， 在单例模式的正常情况下，如果已经在其他地方请求了现有实例，就返回该实例)以解析 `catsService` 。这个依赖会被解析并传递给你的 `controller` 的构造函数 (或分配给指定的属性):

```typescript
constructor(private catsService: CatsService) {}
```

#### 范围

`Providers` 通常拥有一个生命周期 ("scope(译为:范围)") 与应用程序生命周期同步。当应用被启动，每一个依赖必须被解析，因此每一个 `provider` 都必须被实例化。 同样的，当应用关闭，每一个 `provider` 都会被销毁。然而， 有一些方法可以使你的 `provider` 的生命周期也能 **request-scoped(译为:请求范围)** 。 你可以阅读更多关于这些技术 [这里](/fundamentals/injection-scopes).

<app-banner-courses></app-banner-courses>

#### 自定义的provider

`Nest` 拥有一个内置的 inversion of control ("IoC") 容器，用于解析 `providers` 之间的关系。这个特性是上述依赖注入功能的基础，但实际上比我们目前所描述的要强大得多。有多种方式去定义一个 `provider` : 可以使用普通的值、类以及异步或同步工厂函数。更多例子被提供在 [这里](/fundamentals/dependency-injection)。

#### 可选的providers

偶尔，您可能有不一定必须解析的依赖项。例如，你的 `class` 可能依赖于一个 **配置对象**，但是如果没有通过，将会使用默认值。在这个例子中，依赖变成可选的，因为缺少 `configuration provider` 不会导致错误。

为了表面一个 `provider` 是可选的，使用 `@Optional()` 装饰器在构造函数的签名中。

```typescript
import { Injectable, Optional, Inject } from '@nestjs/common';

@Injectable()
export class HttpService<T> {
  constructor(@Optional() @Inject('HTTP_OPTIONS') private httpClient: T) {}
}
```

注意到，在上面的例子中我们使用了一个自定义的 `provider`，这是我们包含 `HTTP_OPTIONS` 自定义 **标识** 的原因。 前面的例子展示了基于构造函数的注入，通过构造函数中的类表面依赖项。 阅读有关自定义提供程序及其关联标识的详细信息 [这里](/fundamentals/custom-providers).

#### 基于属性的注入

我们目前使用的这项技术被称为基于构造函数的注入，因为 `providers` 是通过构造函数的方法注入。 在一些特定的场景下， **基于属性的注入** 或许更加有用。例如，如果你的顶级 `class` 依赖一个或多个 `providers` ，通过从构造函数中调用子类的 `super()` 来传递是非常繁琐的。为了避免这种问题，你可以在属性级别使用 `@Inject()` 装饰器。

```typescript
import { Injectable, Inject } from '@nestjs/common';

@Injectable()
export class HttpService<T> {
  @Inject('HTTP_OPTIONS')
  private readonly httpClient: T;
}
```

> warning **警告** 如果你的 `class` 没有继承其他 `class`，你应该总是使用 **基于构造函数** 的注入。

#### Provider 注册

既然我们定义了一个 `provider` (`CatsService`)，并且我们有一个消费者 (`CatsController`)，我们需要像 `Nest` 注册这个 `service` 以至于它可以执行注入。 我们通过编辑我们的 `module` 文件 (`app.module.ts`) 来做到这点并且添加 `service` 到 `@Module()` 装饰器的 `providers` 数组里。

```typescript
@@filename(app.module)
import { Module } from '@nestjs/common';
import { CatsController } from './cats/cats.controller';
import { CatsService } from './cats/cats.service';

@Module({
  controllers: [CatsController],
  providers: [CatsService],
})
export class AppModule {}
```

`Nest` 现在能够解析 `CatsController` 这个类的依赖。

这就是我们的目录结构:

<div class="file-tree">
<div class="item">src</div>
<div class="children">
<div class="item">cats</div>
<div class="children">
<div class="item">dto</div>
<div class="children">
<div class="item">create-cat.dto.ts</div>
</div>
<div class="item">interfaces</div>
<div class="children">
<div class="item">cat.interface.ts</div>
</div>
<div class="item">cats.controller.ts</div>
<div class="item">cats.service.ts</div>
</div>
<div class="item">app.module.ts</div>
<div class="item">main.ts</div>
</div>
</div>

#### 手动实例化

迄今为止，我们已经讨论了 `Nest` 如何自动地处理依赖关系解决的大部分细节。 在某些情况下，你或许需要跳出内置的依赖关系注入系统，手动检索或实例化提供程序。 我们在下面讨论这两个问题。

为了获取现有实例, 或者动态实例化 `providers`，你可以使用 [模块参考](https://docs.nestjs.com/fundamentals/module-ref).

为了获得 `bootstrap()` 函数内部的 `providers` (例如，对于没有 `controller` 的独立应用， 或者在引导期间使用配置服务) 看 [独立应用](https://docs.nestjs.com/standalone-applications).
