### 第一步

在这篇文章中，您将会了解到 `Nest` 的 **核心基础**。为了熟悉 `Nest` 应用的基本构建模块， 我们将会构建一个基本的 `CRUD` 应用并附带一些涵盖了很多入门级别的内容的特性。

#### 语言

我们钟爱于 [TypeScript](https://www.typescriptlang.org/)， 但最主要的是 - 我们喜欢   [Node.js](https://nodejs.org/en/)。 那就是为什么 `Nest` 同时兼容 `TypeScript` 和 `JavaScript`。 `Nest` 利用了最新的语言特性， 所以为了在 `Nest` 中使用原生的 `Javascript` 我们需要一个[Babel](https://babeljs.io/) 编译器.

在我们提供的例子中我们通常使用 `TypeScript` ， 但是您也可以 **切换代码片段** 成原生的 `JavaScript` 语法 (仅仅只需要点击每个代码片段右上角的语言按钮).

#### 前提条件

请确保 [Node.js](https://nodejs.org) (版本 >= 16) 被安装到您的操作系统.

#### 准备

使用 [Nest CLI](/cli/overview) 创建一个新项目十分简单。 通过 [npm](https://www.npmjs.com/) 安装后， 您可以在您的操作系统终端里通过以下的命令在创建一个新的 `Nest` 项目:

```bash
npm i -g @nestjs/cli
nest new project-name
```

> info **提示** 为了创建一个新的拥有更加严格的特性配置的Typescript项目， 将 `--strict` 标记 添加到 `nest new` 命令之后.

这个 `project-name` 文件家将会被创建， `node_modules` 和一些其他的样板文件将会被安装， 以及一个 `src/` 文件夹将会被创建并且其中包含了一些核心文件。

<div class="file-tree">
  <div class="item">src</div>
  <div class="children">
    <div class="item">app.controller.spec.ts</div>
    <div class="item">app.controller.ts</div>
    <div class="item">app.module.ts</div>
    <div class="item">app.service.ts</div>
    <div class="item">main.ts</div>
  </div>
</div>

以下对这些核心文件的一个简短的概述:

|                          |                                                   |
|--------------------------|---------------------------------------------------|
| `app.controller.ts`      | 一个带有一个单一路由的基本的 `controller`                       |
| `app.controller.spec.ts` | 针对 `controller` 的单元测试                             |
| `app.module.ts`          | 整个应用的根 `module`                                   |
| `app.service.ts`         | 一个带有一个单一方法的基本的 `service`                          |
| `main.ts`                | 整个应用的入口文件，其中使用核心函数 `NestFactory`去创建一个 `Nest` 应用实例 |

这个 `main.ts` 文件包含了一个 `async` 函数， 其将会 **bootstrap(译为:引导)** 我们的应用:

```typescript
@@filename(main)

import
{
  NestFactory
}
from
'@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}

bootstrap();
@@
switch
  import
  {
    NestFactory
  }
    from
    '@nestjs/core';
  import { AppModule } from './app.module';

  async function bootstrap() {
    const app = await NestFactory.create(AppModule);
    await app.listen(3000);
  }

    bootstrap();
```

为了创建一个 `Nest` 应用实例， 我们使用了 `NestFactory` 这个核心类。 `NestFactory` 向外暴露了一些静态方法以允许创建一个应用实例。 这个 `create()` 方法返回一个应用对象， 其实现了 `INestApplication` 这个接口. 这个对象提供了一系列方法，这将会在接下来的章节中介绍。 在上面的 `main.ts` 例子中，我们仅仅启动了我们的 `HTTP` 监听器， 这使得应用可以等待到达的 `HTTP` 请求.

可以看到通过 `Nest CLI` 创建的项目带来了一个初始的项目结构，这可以鼓励开发者们去遵循这套约定以保证每个模块都在自己专有的文件夹中.

> info **提示** 默认情况下， 如果创建应用是发生错误，你的应用将会退出并带有编号 `1`。如果你想要使应用抛出一个错误而不要退出， 禁用 `abortOnError` 这个选项 (例子， `NestFactory.create(AppModule， {{ '{' }} abortOnError: false {{ '}' }})`).

<app-banner-courses></app-banner-courses>

#### 平台

`Nest` 旨在成为一个与平台无关的框架。平台独立使得创建一个可重用的，合乎逻辑的组件成为可能， 以至于开发者可以利用跨多种不同类型的应用程序(express/fastify)的优势。 从技术上说， 只要创建了适配器， `Nest` 就可以与多个`Node HTTP 框架`一起工作。 有两个开箱即用的 HTTP 平台: [express](https://expressjs.com/) 和 [fastify](https://www.fastify.io)。你可以选择一个最符合你的需求的平台。

|                    |                                                                                                                                                                       |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `platform-express` | [Express](https://expressjs.com/) 是一个`nodejs`中熟知的极简的web框架。它是一个经过实战测试的、可用于生产的库，其中包含许多由社区实现的资源。`@nestjs/platform-express` 这个包被默认使用。`Express` 能够满足大多数人的需求， 而且不需要任何操作去激活它 |
| `platform-fastify` | [Fastify](https://www.fastify.io/) 是一个高性能、低成本的框架，高度集中于提供最大限度的效率和速度。 阅读如何使用它 [这里](/techniques/performance).                                                            |

无论哪个平台被使用， `Nest` 都会暴露其它们各自应用程序接口。它们分别为 `NestExpressApplication` 和 `NestFastifyApplication`.

当你传递一个类型给 `NestFactory.create()` 方法时， 在下面的例子中， 这个 `app` 对象将会拥有对应平台的专有方法。 注意， 不管怎样， 你都不 **需要** 指定一个类型 **除非** 你确实想要访问底层平台的API.

```typescript
const app = await NestFactory.create<NestExpressApplication>(AppModule);
```

#### 运行您的应用

一旦安装步骤完成， 你就可以在您的操作系统的终端里运行下面的命令，提示应用开始监听到来的 HTTP 请求:

```bash
npm run start
```

> info **提示** 为了加快开发过程 (构建速度提升x20倍)， 你可以使用 [SWC](/recipes/swc) 通过 传递 `-b swc` 标记给 `start` 脚本， 就像 `npm run start -- -b swc`.

这个命令开启了应用对在 `src/main.ts` 文件中定义的端口的HTTP服务监听。 一旦应用正在运行， 打开您的浏览器并导航到 `http://localhost:3000/` 。你应该可以看到 `Hello World!` 的消息.

为了监听你的文件的变动， 你可以运行下面的命令去启动您的应用:

```bash
npm run start:dev
```

这个命令将会监听你的文件， 自动地重新编译并且重新加载服务器。

#### 语法检查和格式化

[CLI](/cli/overview) 尽最大努力去构建可靠的大规模开发工作流。 因此， 一个生成的 `Nest` 项目预先安装了代码的 **语法检查工具** 和 **格式化工具** (分别是 [eslint](https://eslint.org/) 和 [prettier](https://prettier.io/)).

> info **提示** 不清楚语法检查和格式化的作用? 了解差异 [这里](https://prettier.io/docs/en/comparison.html).

为了确保最大程度的稳定性和扩展性， 我们使用最基础的 [`eslint`](https://www.npmjs.com/package/eslint) 和 [`prettier`](https://www.npmjs.com/package/prettier) 命令行包。这种设置允许通过设计将IDE与官方扩展集成在一起.

对于与IDE无关的环境 (持续集成， Git hooks， 等等) 一个 `Nest` 项目自带即用的 `npm` 脚本。

```bash
# Lint and autofix with eslint
$ npm run lint

# Format with prettier
$ npm run format
```
