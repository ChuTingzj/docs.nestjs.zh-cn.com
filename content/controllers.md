### Controllers控制器

`Controllers` 负责处理到来的 **请求** 并且返回 **响应** 给到客户端。

<figure><img src="/assets/Controllers_1.png" /></figure>

一个 `controller` 的目的就是为应用去接受特定的请求。 这个 **路由** 机制控制着`controller`接受到的每一个请求。通常，每一个`controller` 拥有不止一个路由，并且不同的路由可以执行不同的动作。

为了创建一个基本的`controller`，我们使用 `classes` 和 **decorators装饰器**。 装饰器将`classes`和必要的元数据连系在一起并且允许 `Nest` 去创建一个路由的映射(将请求与对应的 `controllers` 绑定).

> info **提示** 为了快速的创建一个带有 `CRUD` 的 `controller` 并带有内置的[验证](https://docs.nestjs.com/techniques/validation)，你可以使用 `CLI` 的 [CRUD 生成器](https://docs.nestjs.com/recipes/crud-generator#crud-generator): `nest g resource [name]`.

#### 路由

在下面的例子中我们将使用 `@Controller()` 装饰器，这对定义一个基本的 `controller` 是**必要的**。 我们会指定一个可选的路由路径以 `cats` 为前缀。使用一个路径前缀在一个 `@Controller()` 装饰器中允许我们很容易的为一组相关联的路由分组，并且使重复的代码降到最低。例如， 在 `/cats` 这个路由之下，我们会选择为一组路由分组用于管理和猫咪的交互。 在那个例子中， 我们在 `@Controller()` 装饰器中指定了路径前缀 `cats` ，这样我们就不需要在文件中重复书写这个路径。

```typescript
@@filename(cats.controller)
import { Controller, Get } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Get()
  findAll(): string {
    return 'This action returns all cats';
  }
}
@@switch
import { Controller, Get } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Get()
  findAll() {
    return 'This action returns all cats';
  }
}
```

> info **提示** 为了使用`CLI`创建一个`controller`， 仅仅只需要执行 `$ nest g controller [name]` 这个命令

`@Get()` 这个在 `findAll()` 方法之前的HTTP请求的方法装饰器告诉 `Nest` 去为一个HTTP请求的指定端点创建一个处理函数。 这个端点对应着HTTP请求方法(在这个例子中是GET请求) 和路由路径。什么是路由路径? 一个处理函数的路由路径是通过为 `controller` 声明的前缀(可选的)来决定的， 以及任何在方法的装饰器中指定的任何路径。字串我们为每一个路由 ( `cats`) 声明了一个前缀，并且还没有在装饰器中添加任何路径信息， `Nest` 将会映射 `GET /cats` 请求到这个处理函数。 正如前面提到的，路径同时包括了可选的 `controller` 路径前缀 **以及** 任何在请求方法的装饰器中声明的路径字符串。 例如，一个以 `cats` 为前缀的路径和 `@Get('breed')` 这个装饰器相组合将会为请求产生一个路由映射就像 `GET /cats/breed`。

在我们上面的例子中，当一个 `GET` 请求到达这个端点， `Nest` 会将请求路由至我们用户定义的 `findAll()` 方法。 注意这里我们选择的这个方法名是完全任意的。 很明显，我们必须声明一个方法去绑定这个路由，但是 `Nest` 不会为这个选中的方法名附加任何签名。

这个方法将会返回一个200的状态码以及相关联的响应，在这个例子中响应只是一个字符串。 为什么会这样? 为了解释这个，我们将首先介绍 `Nest` 使用两种不同的选项来操纵响应的这个概念:

<table>
  <tr>
    <td>标准的 (推荐)</td>
    <td>
      使用这些内置的方法，当一个请求处理函数返回一个<code>JavaScript</code>对象或数组时， 返回值就会<strong>自动地</strong>
      被序列化成<code>JSON</code>。当返回值是一个<code>JavaScript</code>原始类型时(例如, <code>string</code>, <code>number</code>, <code>boolean</code>), 尽管如此, `Nest` 仅仅会返回它而没有尝试进行序列化。 这使得处理响应变得简单: 仅仅返回这个值，然后剩下的就交给 <code>Nest</code>。
      <br />
      <br /> 此外，这个响应的 <strong>状态码</strong> 默认总是200， 除了对于POST
      请求使用201。我们可以轻松的改变这样的行为通过在处理函数上添加<code>@HttpCode(...)</code>
      装饰器(请看 <a href='controllers#status-code'>Status codes</a>).
    </td>
  </tr>
  <tr>
    <td>库特有的</td>
    <td>
      我么可以使用库特有的 (例如, Express) <a href="https://expressjs.com/en/api.html#res" rel="nofollow" target="_blank">响应对象</a>，这些响应对象可以被注入通过使用 <code>@Res()</code> 装饰器在方法处理函数的签名上 (例如, <code>findAll(@Res() response)</code>).  通过这种方式, 你能够使用这个对象暴露的原生的响应处理方法。例如，通过 <code>Express</code>，你可以使用代码构造响应就像 <code>response.status(200).send()</code>.
    </td>
  </tr>
</table>

> warning **警告** 当处理函数正在使用 `@Res()` 或者 `@Next()`时，`Nest` 将会检测，指示你已经选择了 `library-specific(译为:库特有的)` 的方式。如果这两种方式同时被使用，标准的方式会被 **自动地禁止** 对于这个单一的路由，并且将不在如预期的那样工作。为了同时使用这两种方式 (例如，通过注入 <code>response</code> 对象去只设置 `cookies/headers` 但是仍然将留下的交给框架)，你必须在 `@Res({{ '{' }} passthrough: true {{ '}' }})` 装饰器中设置 `passthrough` 选项为 `true`。

<app-banner-devtools></app-banner-devtools>

#### 请求对象

处理函数经常需要访问客户端 **请求** 的详细信息。 `Nest` 提供了对于底层平台(默认为 `Express` )的 [请求对象](https://expressjs.com/en/api.html#req) 的访问。 我们可以访问请求对象通过添加 `@Req()` 装饰器在处理函数的签名里以告知 `Nest` 去注入请求对象。

```typescript
@@filename(cats.controller)
import { Controller, Get, Req } from '@nestjs/common';
import { Request } from 'express';

@Controller('cats')
export class CatsController {
  @Get()
  findAll(@Req() request: Request): string {
    return 'This action returns all cats';
  }
}
@@switch
import { Controller, Bind, Get, Req } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Get()
  @Bind(Req())
  findAll(request) {
    return 'This action returns all cats';
  }
}
```

> info **提示** 为了利用 `express` 的完整类型提示(就像上面的例子中的 `request: Request`)，可以安装 `@types/express` 这个包。

请求对象代表着带有 `query`参数、`param`参数、`header`、`body`等各种属性 (阅读更多 [这里](https://expressjs.com/en/api.html#req)) 的HTTP请求。 在大多数场景中，没有必要去手动获取这些信息。我们可以使用专门的装饰器，例如 `@Body()` 或者 `@Query()`，这些装饰器可以让我们不必进入请求对象内部去访问这些属性。 下面是一个提供的装饰器的列表以及他们表示的特定平台的普通对象。

<table>
  <tbody>
    <tr>
      <td><code>@Request(), @Req()</code></td>
      <td><code>req</code></td></tr>
    <tr>
      <td><code>@Response(), @Res()</code><span class="table-code-asterisk">*</span></td>
      <td><code>res</code></td>
    </tr>
    <tr>
      <td><code>@Next()</code></td>
      <td><code>next</code></td>
    </tr>
    <tr>
      <td><code>@Session()</code></td>
      <td><code>req.session</code></td>
    </tr>
    <tr>
      <td><code>@Param(key?: string)</code></td>
      <td><code>req.params</code> / <code>req.params[key]</code></td>
    </tr>
    <tr>
      <td><code>@Body(key?: string)</code></td>
      <td><code>req.body</code> / <code>req.body[key]</code></td>
    </tr>
    <tr>
      <td><code>@Query(key?: string)</code></td>
      <td><code>req.query</code> / <code>req.query[key]</code></td>
    </tr>
    <tr>
      <td><code>@Headers(name?: string)</code></td>
      <td><code>req.headers</code> / <code>req.headers[name]</code></td>
    </tr>
    <tr>
      <td><code>@Ip()</code></td>
      <td><code>req.ip</code></td>
    </tr>
    <tr>
      <td><code>@HostParam()</code></td>
      <td><code>req.hosts</code></td>
    </tr>
  </tbody>
</table>

为了与底层的HTTP平台类型兼容(例如， Express 和 Fastify)， `Nest` 提供了 `@Res()` 和 `@Response()` 装饰器。 `@Res()` 只是 `@Response()` 的别名。两者都直接暴露了底层的原生平台的 `response` 对象接口。当使用它们时，你需要为底层的库引入类型(例如， `@types/express`) 以获得更好的类型提示。注意，当你在一个方法处理函数内注入 `@Res()` 或者 `@Response()` 时，你需要使 `Nest` 进入 **Library-specific(译为:特定库) 模式** 为那个处理函数，之后你将负责管理 `response`。当这样做时，你必须通过调用 `response` 对象上的一些方法(例如， `res.json(...)` or `res.send(...)`)来做出响应，否则HTTP 服务器会挂起。

> info **提示** 为了了解如何书写你自己的装饰器，访问 [这个章节](/custom-decorators)。

#### 资源

早些时候，我们定义了一个端点来获得一些猫咪的资源 (**GET** 路由)。 我们通常也会想要提供一个端点用于创建一条新的记录。为了实现这个需求，让我们创建 **POST** 处理函数:

```typescript
@@filename(cats.controller)
import { Controller, Get, Post } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Post()
  create(): string {
    return 'This action adds a new cat';
  }

  @Get()
  findAll(): string {
    return 'This action returns all cats';
  }
}
@@switch
import { Controller, Get, Post } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Post()
  create() {
    return 'This action adds a new cat';
  }

  @Get()
  findAll() {
    return 'This action returns all cats';
  }
}
```

这是一个例子。 `Nest` 提供了所有的HTTP方法的装饰器： `@Get()`, `@Post()`, `@Put()`, `@Delete()`, `@Patch()`, `@Options()`, 以及 `@Head()`。 另外， `@All()` 这个装饰器定义了一个端点用于处理所有的HTTP方法。

#### 路由通配符

基于模式匹配的路由也同样支持。 例如，星号常常被用作通配符，可以匹配任意字符组合。

```typescript
@Get('ab*cd')
findAll() {
  return 'This route uses a wildcard';
}
```

`'ab*cd'` 这个路由将会匹配 `abcd`， `ab_cd`， `abecd`， 等等。 字符 `?`， `+`， `*`， 以及 `()` 都可以被用在路由的路径当中，和是对应正则表达式的子集。连字符 ( `-`) 以及 点符号 (`.`) 都会被基于字符串的路径按字面意义解析。

> warning **警告** `express` 仅仅支持位于路由中间的通配符。

#### 状态码

如之前所述，响应 **状态码** 默认总是 **200** ，除了对于POST 请求使用 **201** 。我们可以轻松的改变这样的行为通过在处理函数上添加 `@HttpCode(...)` 装饰器。

```typescript
@Post()
@HttpCode(204)
create() {
  return 'This action adds a new cat';
}
```

> info **提示** 从 `@nestjs/commn` 这个包中引入 `HttpCode` 这个装饰器

通常，你的状态码不会是静态的，这依赖于各种因素。在这种情况下，你可以使用指定库的 **response** (通过使用 `@Res()` 注入) 对象 (或者, 以防错误, 可以引发异常)。

#### 头信息

为了指定一个定制化的头信息，你既可以使用 `@Header()` 装饰器也可以通过指定库的 `response` 对象(直接调用 `res.header()`)。

```typescript
@Post()
@Header('Cache-Control', 'none')
create() {
  return 'This action adds a new cat';
}
```

> info **提示** 从 `@nestjs/commn` 这个包中引入 `Header` 这个装饰器

#### 重定向

为了重定向一个 `response` 至一个指定的 `URL`，你既可以使用 `@Redirect()` 装饰器也可以使用指定库的 `response` 对象 (直接调用 `res.redirect()`)。

`@Redirect()` 拥有两个参数， `url` 和 `statusCode`，两者都是可选的。默认的 `statusCode` 是 `302` 如果省略。

```typescript
@Get()
@Redirect('https://nestjs.com', 301)
```

> info **提示** 有时，你可能想要动态地决定HTTP的状态码或者重定向的 `URL` 。 通过返回一个对象(参考 `HttpRedirectResponse` 这个接口 (来自 `@nestjs/common`)。

返回的值将会重写传递给 `@Redirect()` 装饰器内的参数。 例如：

```typescript
@Get('docs')
@Redirect('https://docs.nestjs.com', 302)
getDocs(@Query('version') version) {
  if (version && version === '5') {
    return { url: 'https://docs.nestjs.com/v5/' };
  }
}
```

#### 路由参数

静态路由不会生效当你需要从请求的一部分(例如， `GET /cats/1` 可以获得id为`1`的猫咪)接受 **动态的数据** 。 为了定义带有参数的路由，我们可以在路由的路径中添加路由参数的 **tokens(译为:标识)** 去捕获位于请求 `URL` 的那个位置的动态值。下面 `@Get()` 装饰器示例中的路由参数标识演示了这种用法。 使用这种方式声明的路由参数可以使用 `@Param()` 装饰器去接收，这个装饰器应当被添加在对应方法的签名中。

> info **提示** 带有参数的路由应当被声明在任意的静态路径之后。这可以阻止带有参数路径拦截发往静态路径的流量。

```typescript
@@filename()
@Get(':id')
findOne(@Param() params: any): string {
  console.log(params.id);
  return `This action returns a #${params.id} cat`;
}
@@switch
@Get(':id')
@Bind(Param())
findOne(params) {
  console.log(params.id);
  return `This action returns a #${params.id} cat`;
}
```

`@Param()` 被用于装饰一个方法签名 (在上面的例子是 `params` )，它使得 **路由** 参数在方法体中可以通过方法的形参被访问。 正如上面的代码所示，我们可以通过引用 `params.id` 进入 `id` 参数。 你也可以将特定的参数标识传递给此装饰器，然后就可以被在方法体中直接引用该参数。

> info **提示** 从 `@nestjs/common` 引入 `Param`

```typescript
@@filename()
@Get(':id')
findOne(@Param('id') id: string): string {
  return `This action returns a #${id} cat`;
}
@@switch
@Get(':id')
@Bind(Param('id'))
findOne(id) {
  return `This action returns a #${id} cat`;
}
```

#### 子路由

`@Controller` 这个装饰器拥有一个 `host` 选项用来要求到达的请求的HTTP主机名匹配一些特定的值.

```typescript
@Controller({ host: 'admin.example.com' })
export class AdminController {
  @Get()
  index(): string {
    return 'Admin page';
  }
}
```

> **警告** 由于 **Fastify** 不支持嵌套的路由，当使用子路由时， 应当使用 (默认的) `Express` 适配器。

与路由的 `path` 相似，  `hosts` 这个选项可以使用一些标识在主机名中去捕获在某些位置特定的值。 下面的例子演示了，`@Controller()` 装饰器中的主机参数标识这个用法。使用这种方式声明的主机参数可以被通过 `@HostParam()` 装饰器装饰的方法的签名里访问。

```typescript
@Controller({ host: ':account.example.com' })
export class AccountController {
  @Get()
  getInfo(@HostParam('account') account: string) {
    return account;
  }
}
```

#### 范围

对于具有不同编程语言的背景的人来说，在 `Nest` 中， 几乎所有东西都可以跨越到达的请求被共享，对此会感到意外。我们拥有一个数据库的连接池，具有全局状态的单例服务，等等。 请记住 `Node.js` 不遵循请求/响应多线程无状态模型，其中每个请求都由单独的线程处理。 因此，对于我们的应用，使用单例是完全 **安全** 的。

然而，在某些情况下基于请求的 `controller` 的生命周期可能是期望的行为，例如，`GraphQL` 应用中的每个请求的缓存、请求跟踪或多租户。了解如何控制范围 [这里](/fundamentals/injection-scopes).

#### 异步性

我们喜欢现代化的 `JavaScript` 并且我们知道数据获取大多数是 **异步的**。这就是为什么 `Nest` 对于 `async` 函数支持并很好的使用。

> info **提示** 了解跟多关于 `async / await` 特性 [这里](https://kamilmysliwiec.com/typescript-2-1-introduction-async-await)

所有的 `async` 函数必须返回 `Promise`。这意味着你可以返回一个延迟的值，`Nest` 会自己解析该值。让我们看看下面这个例子:

```typescript
@@filename(cats.controller)
@Get()
async findAll(): Promise<any[]> {
  return [];
}
@@switch
@Get()
async findAll() {
  return [];
}
```

上面的代码是完全有效的。 此外， `Nest` 路由处理函数功能更加强大以至于可以返回 RxJS [observable streams(译为:可观察流)](http://reactivex.io/rxjs/class/es6/Observable.js~Observable.html)。 `Nest` 会自动订阅底层的源并获取最后发出的值 (一旦流完成)。

```typescript
@@filename(cats.controller)
@Get()
findAll(): Observable<any[]> {
  return of([]);
}
@@switch
@Get()
findAll() {
  return of([]);
}
```

上面的两种方式都是有效的，你可以使用任意符合你需求的方式。

#### 请求载荷

我们的之前 POST 处理函数的例子没有接收任何客户端参数。让我们填补这个空缺通过在这里添加 `@Body()` 装饰器。

但是首先 (如果你使用 `TypeScript` )，我们需要确定 **DTO** (数据传输对象) 结构。一个 `DTO` 是一个定义了数据如何通过网络传输的对象。我们可以确定 `DTO` 结构通过使用 **TypeScript** 接口，或者通过简单的 `classes` 。 有趣的是，这里我们推荐使用 **classes**。 为什么呢? `Classes` 并不是 `JavaScript ES6` 标准的一部分，因此它们可以作为实体被保存在编译过的 `JavaScript` 中。 另一方面，由于 `TypeScript` 接口会在转译期间被擦除， `Nest` 不能在运行时引用它们。这点很重要，因为像 **Pipes(译为:管道)** 这样必须在运行时访问变量的元类型的特性需借此以启用其他附加的功能。

让我们创建 `CreateCatDto` 这个类:

```typescript
@@filename(create-cat.dto)
export class CreateCatDto {
  name: string;
  age: number;
  breed: string;
}
```

它仅拥有三个基础属性。 此后，我们可以在 `CatsController` 内部使用新创建的 `DTO`:

```typescript
@@filename(cats.controller)
@Post()
async create(@Body() createCatDto: CreateCatDto) {
  return 'This action adds a new cat';
}
@@switch
@Post()
@Bind(Body())
async create(createCatDto) {
  return 'This action adds a new cat';
}
```

> info **提示** 我们的 `ValidationPipe` 可以过滤不需要被方法处理函数接收的属性。在这个例子中，我们可以将可接受的属性列入白名单，然后任何没有包含在白名单内的属性会在生成的对象中自动被跳过。在 `CreateCatDto` 例子中，我们的白名单是 `name`， `age`， 和 `breed` 三个属性。了解更多[这里](https://docs.nestjs.com/techniques/validation#stripping-properties)。

#### 错误处理

有一个是关于错误处理的单独章节 (即, 处理异常) [这里](/exception-filters).

#### 完整资源示例

下面的是一个例子， 利用了多个可用的装饰器用来创建一个基本的 `controller` 。 这个 `controller` 暴露了几个方法用来访问和操纵内部的数据。

```typescript
@@filename(cats.controller)
import { Controller, Get, Query, Post, Body, Put, Param, Delete } from '@nestjs/common';
import { CreateCatDto, UpdateCatDto, ListAllEntities } from './dto';

@Controller('cats')
export class CatsController {
  @Post()
  create(@Body() createCatDto: CreateCatDto) {
    return 'This action adds a new cat';
  }

  @Get()
  findAll(@Query() query: ListAllEntities) {
    return `This action returns all cats (limit: ${query.limit} items)`;
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return `This action returns a #${id} cat`;
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateCatDto: UpdateCatDto) {
    return `This action updates a #${id} cat`;
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return `This action removes a #${id} cat`;
  }
}
@@switch
import { Controller, Get, Query, Post, Body, Put, Param, Delete, Bind } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Post()
  @Bind(Body())
  create(createCatDto) {
    return 'This action adds a new cat';
  }

  @Get()
  @Bind(Query())
  findAll(query) {
    console.log(query);
    return `This action returns all cats (limit: ${query.limit} items)`;
  }

  @Get(':id')
  @Bind(Param('id'))
  findOne(id) {
    return `This action returns a #${id} cat`;
  }

  @Put(':id')
  @Bind(Param('id'), Body())
  update(id, updateCatDto) {
    return `This action updates a #${id} cat`;
  }

  @Delete(':id')
  @Bind(Param('id'))
  remove(id) {
    return `This action removes a #${id} cat`;
  }
}
```

> info **提示** `Nest CLI` 提供了一个 `generator(译为:生成器)` (有结构的) 用于自动生成 **所有的样板代码** 以帮助我们避免手动的做这件事，并且使得开发体验更加简单。阅读跟多关于此特性[这里](/recipes/crud-generator).

#### 启动和运行

完全定义上述 `controller` 后， `Nest` 任然不知道 `CatsController` 的存在，结果就导致 `Nest` 不会创建这个类的实例。

`Controllers` 总是属于一个 `module`，这就是为什么我们在 `@Module()` 装饰器内部包含 `controllers` 数组。 应为我们还没定义任何 `modules` 除了根 `AppModule`，我们将会使用这篇章节来介绍 `CatsController`:

```typescript
@@filename(app.module)
import { Module } from '@nestjs/common';
import { CatsController } from './cats/cats.controller';

@Module({
  controllers: [CatsController],
})
export class AppModule {}
```

我们使用 `@Module()` 装饰器来绑定元数据到这个 `module class` ，然后 `Nest` 现在就会轻松地反射出哪些 `controllers` 必须被挂载。

#### 特定库的方式

目前我们以及讨论了 `Nest` 的标准方式去操纵 `responses`。第二种操纵 `response` 的方式就是使用 `library-specific(译为:指定库的)` 方式 [响应对象](https://expressjs.com/en/api.html#res)。为了注入一个特定的 `response` 对象，我们需要使用 `@Res()` 装饰器。为了展示差异，让我们跟随下面的例子重写 `CatsController` :

```typescript
@@filename()
import { Controller, Get, Post, Res, HttpStatus } from '@nestjs/common';
import { Response } from 'express';

@Controller('cats')
export class CatsController {
  @Post()
  create(@Res() res: Response) {
    res.status(HttpStatus.CREATED).send();
  }

  @Get()
  findAll(@Res() res: Response) {
     res.status(HttpStatus.OK).json([]);
  }
}
@@switch
import { Controller, Get, Post, Bind, Res, Body, HttpStatus } from '@nestjs/common';

@Controller('cats')
export class CatsController {
  @Post()
  @Bind(Res(), Body())
  create(res, createCatDto) {
    res.status(HttpStatus.CREATED).send();
  }

  @Get()
  @Bind(Res())
  findAll(res) {
     res.status(HttpStatus.OK).json([]);
  }
}
```

尽管这种方式生效, 而且实际上是通过对响应对象的完全控制，在某些方面提供了更大的灵活性(头信息操纵，指定库的特性， 等等)， 但是这种方式还是应该小心使用。 通常，这种方式不太清除，并且有一些弊端。主要的弊端是，你的代码变成了 `platform-dependent(译为:依赖平台)` 的(因为底层库在响应对象上可能具有不同的 API)，并且难以测试 (你必须 `mock` 响应对象, 例如)。

同时，在上面的例子中，你失去依赖于 `Nest` 标准响应处理与 `Nest` 特性的兼容性，例如拦截器以及 `@HttpCode()` / `@Header()` 装饰器。为了解决这个问题，你可以设置 `passthrough` 选项为 `true`， 就像下面这样:

```typescript
@@filename()
@Get()
findAll(@Res({ passthrough: true }) res: Response) {
  res.status(HttpStatus.OK);
  return [];
}
@@switch
@Get()
@Bind(Res({ passthrough: true }))
findAll(res) {
  res.status(HttpStatus.OK);
  return [];
}
```

现在你可以与原生的响应对象交互(例如，根据某些条件，设置 `cookies` 或者 `headers`)， 剩下的交给框架。
