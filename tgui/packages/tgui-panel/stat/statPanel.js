

import { Component } from 'inferno';
export class StatPanel extends Component {
  constructor() {
    super();
    this.selectedTab = 'Status';
  }

  setTab(newTab) {
    this.selectedTab = newTab;
  }

}
