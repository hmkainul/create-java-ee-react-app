# create-java-ee-react-app

`create-java-ee-react-app.sh` is a shell script for bootstrapping Java EE 8 and React project on macOS.

Script downloads JDK, Maven, Payara and Node.

It uses Adam Bien's Maven template to create a Java EE 8 project containing a JAX-RS REST service.

Then it calls `create-react-app` and creates a React project. It also modifies `package.json` and `App.js` so that React frontend calls Java EE backend.

## package.json modifications

```diff
{
  "name": "frontend",
+ "proxy": "http://localhost:8080/",
  "version": "0.1.0",
```

## App.js modifications

```diff
import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {
+ constructor(props) {
+   super(props)
+   this.state = { 'greeting': '' }
+ }
+ componentWillMount() {
+   fetch('/backend/resources/ping')
+     .then(response => response.text())
+     .then(text => this.setState({ 'greeting': text }))
+ }
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <p>
            Edit <code>src/App.js</code> and save to reload.
          </p>
          <a
            className="App-link"
            href="https://reactjs.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            Learn React
          </a>
+         <p>{this.state.greeting}</p>
        </header>
      </div>
    );
  }
}

export default App;
```
