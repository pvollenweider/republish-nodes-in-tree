import javax.jcr.NodeIterator
import javax.jcr.PathNotFoundException
import javax.jcr.RepositoryException
import javax.jcr.query.Query
import org.jahia.api.Constants
import org.jahia.registries.ServicesRegistry
import org.jahia.services.content.*
import org.jahia.services.content.JCRCallback
import org.jahia.services.content.JCRContentUtils
import org.jahia.services.content.JCRNodeWrapper
import org.jahia.services.content.JCRSessionWrapper
import org.jahia.services.content.JCRTemplate
import org.jahia.services.sites.JahiaSite
import org.jahia.services.usermanager.JahiaUserManagerService

def JCRTemplate jcrTemplate;


String startPath = params.get("startPath")[0];
String nodeType = params.get("nodeType")[0];
boolean testOnly = params.get("testOnly") != null;
boolean forcePublication = params.get("forcePublication") != null;

/*
print "<br/>Start path is " + startPath;

print "<br/>nodeType is " + nodeType;
print "<br/>testOnly is " + testOnly;
print "<br/>forcePublication is " + forcePublication;
print "<br/>";
*/
Set<String> nodesToAutoPublish = new HashSet<String>();
Set<String> nodesWithPendingModifications = new HashSet<String>();


JCRSessionWrapper session = JCRSessionFactory.getInstance().getCurrentSystemSession(Constants.EDIT_WORKSPACE, null, null);
try {
    JCRNodeWrapper start = session.getNode(startPath);
    if (start.isNodeType(nodeType)) {
        if (!hasPendingModification(start) || forcePublication) {
            //  "touch" the node then add it to publish list
            try {
                start.setProperty("jcr:lastModified", new GregorianCalendar());
                nodesToAutoPublish.add(start.identifier);
            } catch (javax.jcr.nodetype.ConstraintViolationException e) {
            }
        }
    }
    def q = "select * from [" + nodeType + "] where isdescendantnode('" + startPath + "')";
    NodeIterator iterator = session.getWorkspace().getQueryManager().createQuery(q, Query.JCR_SQL2).execute().getNodes();
    while (iterator.hasNext()) {
        final JCRNodeWrapper node = (JCRNodeWrapper) iterator.nextNode();
        //print (node.getPath() + "<br/>");
        // check if node has pending updates
        if (!hasPendingModification(node) || forcePublication) {
            //  "touch" the node then add it to publish list
            try {
                node.setProperty("jcr:lastModified", new GregorianCalendar());
                nodesToAutoPublish.add(node.identifier);
            } catch (javax.jcr.nodetype.ConstraintViolationException e) {
            }
        } else {
            nodesWithPendingModifications.add(node.identifier);
        }
    }
    if (!testOnly) {
        session.save();
    }
} catch (Exception e) {
    println "Error:  $e.message"
}
if (!nodesToAutoPublish.isEmpty()) {
    if (!testOnly) {
        JCRPublicationService.getInstance().publish(nodesToAutoPublish.asList(), Constants.EDIT_WORKSPACE, Constants.LIVE_WORKSPACE, false, null)
    };
    print("<h3>Republished node</h3>")
    print("<pre class=\"p-3 bg-white shadow\"><code>")
    for (String identifier : nodesToAutoPublish) {
        println(session.getNodeByIdentifier(identifier).getPath());
    }
    print("</code></pre>")
}

if (!nodesWithPendingModifications.isEmpty()) {
    print("<h3>Unpublished nodes (pending modification):</h3>")
    print("<pre class=\"p-3 bg-white shadow\"><code>")
    for (String identifier : nodesWithPendingModifications) {
        println(session.getNodeByIdentifier(identifier).getPath());
    }

}

private boolean hasPendingModification(JCRNodeWrapper node) {
    if (!node.hasProperty("j:lastPublished")) return true
    if (!node.hasProperty("j:published") || !node.getProperty("j:published").getBoolean()) return true
    java.util.Calendar lastModified = node.getProperty("jcr:lastModified").getDate()
    java.util.Calendar lastPublished = node.getProperty("j:lastPublished").getDate()
    return lastModified > lastPublished
}
