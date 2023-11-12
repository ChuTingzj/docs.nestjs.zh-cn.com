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

#### Route parameters

Routes with static paths won't work when you need to accept **dynamic data** as part of the request (e.g., `GET /cats/1` to get cat with id `1`). In order to define routes with parameters, we can add route parameter **tokens** in the path of the route to capture the dynamic value at that position in the request URL. The route parameter token in the `@Get()` decorator example below demonstrates this usage. Route parameters declared in this way can be accessed using the `@Param()` decorator, which should be added to the method signature.

> info **Hint** Routes with parameters should be declared after any static paths. This prevents the parameterized paths from intercepting traffic destined for the static paths.

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

`@Param()` is used to decorate a method parameter (`params` in the example above), and makes the **route** parameters available as properties of that decorated method parameter inside the body of the method. As seen in the code above, we can access the `id` parameter by referencing `params.id`. You can also pass in a particular parameter token to the decorator, and then reference the route parameter directly by name in the method body.

> info **Hint** Import `Param` from the `@nestjs/common` package.

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

#### Sub-Domain Routing

The `@Controller` decorator can take a `host` option to require that the HTTP host of the incoming requests matches some specific value.

```typescript
@Controller({ host: 'admin.example.com' })
export class AdminController {
  @Get()
  index(): string {
    return 'Admin page';
  }
}
```

> **Warning** Since **Fastify** lacks support for nested routers, when using sub-domain routing, the (default) Express adapter should be used instead.

Similar to a route `path`, the `hosts` option can use tokens to capture the dynamic value at that position in the host name. The host parameter token in the `@Controller()` decorator example below demonstrates this usage. Host parameters declared in this way can be accessed using the `@HostParam()` decorator, which should be added to the method signature.

```typescript
@Controller({ host: ':account.example.com' })
export class AccountController {
  @Get()
  getInfo(@HostParam('account') account: string) {
    return account;
  }
}
```

#### Scopes

For people coming from different programming language backgrounds, it might be unexpected to learn that in Nest, almost everything is shared across incoming requests. We have a connection pool to the database, singleton services with global state, etc. Remember that Node.js doesn't follow the request/response Multi-Threaded Stateless Model in which every request is processed by a separate thread. Hence, using singleton instances is fully **safe** for our applications.

However, there are edge-cases when request-based lifetime of the controller may be the desired behavior, for instance per-request caching in GraphQL applications, request tracking or multi-tenancy. Learn how to control scopes [here](/fundamentals/injection-scopes).

#### Asynchronicity

We love modern JavaScript and we know that data extraction is mostly **asynchronous**. That's why Nest supports and works well with `async` functions.

> info **Hint** Learn more about `async / await` feature [here](https://kamilmysliwiec.com/typescript-2-1-introduction-async-await)

Every async function has to return a `Promise`. This means that you can return a deferred value that Nest will be able to resolve by itself. Let's see an example of this:

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

The above code is fully valid. Furthermore, Nest route handlers are even more powerful by being able to return RxJS [observable streams](http://reactivex.io/rxjs/class/es6/Observable.js~Observable.html). Nest will automatically subscribe to the source underneath and take the last emitted value (once the stream is completed).

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

Both of the above approaches work and you can use whatever fits your requirements.

#### Request payloads

Our previous example of the POST route handler didn't accept any client params. Let's fix this by adding the `@Body()` decorator here.

But first (if you use TypeScript), we need to determine the **DTO** (Data Transfer Object) schema. A DTO is an object that defines how the data will be sent over the network. We could determine the DTO schema by using **TypeScript** interfaces, or by simple classes. Interestingly, we recommend using **classes** here. Why? Classes are part of the JavaScript ES6 standard, and therefore they are preserved as real entities in the compiled JavaScript. On the other hand, since TypeScript interfaces are removed during the transpilation, Nest can't refer to them at runtime. This is important because features such as **Pipes** enable additional possibilities when they have access to the metatype of the variable at runtime.

Let's create the `CreateCatDto` class:

```typescript
@@filename(create-cat.dto)
export class CreateCatDto {
  name: string;
  age: number;
  breed: string;
}
```

It has only three basic properties. Thereafter we can use the newly created DTO inside the `CatsController`:

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

> info **Hint** Our `ValidationPipe` can filter out properties that should not be received by the method handler. In this case, we can whitelist the acceptable properties, and any property not included in the whitelist is automatically stripped from the resulting object. In the `CreateCatDto` example, our whitelist is the `name`, `age`, and `breed` properties. Learn more [here](https://docs.nestjs.com/techniques/validation#stripping-properties).

#### Handling errors

There's a separate chapter about handling errors (i.e., working with exceptions) [here](/exception-filters).

#### Full resource sample

Below is an example that makes use of several of the available decorators to create a basic controller. This controller exposes a couple of methods to access and manipulate internal data.

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

> info **Hint** Nest CLI provides a generator (schematic) that automatically generates **all the boilerplate code** to help us avoid doing all of this, and make the developer experience much simpler. Read more about this feature [here](/recipes/crud-generator).

#### Getting up and running

With the above controller fully defined, Nest still doesn't know that `CatsController` exists and as a result won't create an instance of this class.

Controllers always belong to a module, which is why we include the `controllers` array within the `@Module()` decorator. Since we haven't yet defined any other modules except the root `AppModule`, we'll use that to introduce the `CatsController`:

```typescript
@@filename(app.module)
import { Module } from '@nestjs/common';
import { CatsController } from './cats/cats.controller';

@Module({
  controllers: [CatsController],
})
export class AppModule {}
```

We attached the metadata to the module class using the `@Module()` decorator, and Nest can now easily reflect which controllers have to be mounted.

#### Library-specific approach

So far we've discussed the Nest standard way of manipulating responses. The second way of manipulating the response is to use a library-specific [response object](https://expressjs.com/en/api.html#res). In order to inject a particular response object, we need to use the `@Res()` decorator. To show the differences, let's rewrite the `CatsController` to the following:

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

Though this approach works, and does in fact allow for more flexibility in some ways by providing full control of the response object (headers manipulation, library-specific features, and so on), it should be used with care. In general, the approach is much less clear and does have some disadvantages. The main disadvantage is that your code becomes platform-dependent (as underlying libraries may have different APIs on the response object), and harder to test (you'll have to mock the response object, etc.).

Also, in the example above, you lose compatibility with Nest features that depend on Nest standard response handling, such as Interceptors and `@HttpCode()` / `@Header()` decorators. To fix this, you can set the `passthrough` option to `true`, as follows:

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

Now you can interact with the native response object (for example, set cookies or headers depending on certain conditions), but leave the rest to the framework.
