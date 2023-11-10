### 介绍

`Nest`是一个用于构建高效、可扩展的[Node.js](https://nodejs.org/) 服务端侧应用的框架。`Nest` 采用渐进式 `Javascript` ，使用 `Typescript` 构建并完全支持 [TypeScript](http://www.typescriptlang.org/) (但仍然允许开发人员用纯 `JavaScript` 编写代码) 并且结合了 OOP (面向对象编程)， FP (函数式编程)， 和 FRP (函数响应式编程) 的编程范式.

在底层， `Nest` 利用健壮的HTTP服务器框架像[Express](https://expressjs.com/) (默认采用) 并且也可选择的可以配置为使用[Fastify](https://github.com/fastify/fastify)!

在这些通用的`Nodejs`框架(Express/Fastify)之上`Nest` 提供了一定程度的抽象， 但同时也将这些框架的API直接暴露给了开发者。这使得开发者们可以自由的去使用这些底层框架(Express/Fastify)的大量的第三方模块。

#### 设计理念

近些年来， 感谢 `Node.js`， `JavaScript` 已经成为了前端和后端应用的 “通用语言”. 这已经带来了一些令人惊叹的项目就像 [Angular](https://angular.io/)， [React](https://github.com/facebook/react) 和 [Vue](https://github.com/vuejs/vue)， 这些项目改善了开发者的生产力并且使构建快速、可测试和可扩展的前端应用成为可能。 然而， 尽管 `Node` (服务端侧的 `Javascript` )拥有大量卓越的库，辅助工具， 但是这些生态没有一个能够有效的解决现存的主要问题 - **架构**.

`Nest` 提供了一个开箱即用的应用架构，这允许开发者和团队构建高度可测试、可扩展， 低耦合， 并且易于维护的应用。 这个架构受 `Angular` 深度启发。

#### 安装

为了开始， 你既可以使用 [Nest CLI](/cli/overview) 搭建项目的脚手架， 也可以克隆一个初试项目 (两种方法都会产生相同的效果).

为了使用 `Nest CLI` 搭建项目的脚手架， 请运行如下的命令。这将会创建一个新的项目文件夹， 并且用初始核心Nest文件和相关支持模块填充目录， 为你的项目创建一个常规的基础的结构。 对于初次使用者，使用 **Nest CLI** 创建一个新项目是比较推荐的方式。我们将会使用这种方法继续下去在 [First Steps](first-steps).

```bash
npm i -g @nestjs/cli
nest new project-name
```

> info **提示**  为了创建一个新的拥有更加严格的特性配置的Typescript项目， 将 `--strict` 标记 添加到 `nest new` 命令之后.

#### 替换方案

另外的一种方式， 使用 **Git** 去安装Typescript的开始项目:

```bash
git clone https://github.com/nestjs/typescript-starter.git project
cd project
npm install
npm run start
```

> info **提示** 如果你想要克隆没有git历史记录的仓库， 你可以使用 [degit](https://github.com/Rich-Harris/degit).

打开您的浏览器并导航到 [`http://localhost:3000/`](http://localhost:3000/).

如果想要安装Javascript风格的开始项目， 在上面的命令行中使用 `javascript-starter.git` .

你也可以从零开始手动的创建一个新项目通过 **npm** (或者 **yarn**)等包管理工具安装Nest的核心包和相关支持的文件。 在这个例子中， 当然， 您将自己负责创建样板文件。

```bash
npm i --save @nestjs/core @nestjs/common rxjs reflect-metadata
```
