# create-java-ee-react-app
Shell script for bootstrapping Java EE and React project

### package.json

```diff
{
  "name": "frontend",
+  "proxy": "http://localhost:8080/",
  "version": "0.1.0",
```

### App.js

```diff
import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {
+  constructor(props) {
+    super(props)
+    this.state = { 'greeting': '' }
+  }
+  componentWillMount() {
+    fetch('/backend/resources/ping')
+      .then(response => response.text())
+      .then(text => this.setState({ 'greeting': text }))
+  }
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
+          <p>{this.state.greeting}</p>
        </header>
      </div>
    );
  }
}

export default App;

```