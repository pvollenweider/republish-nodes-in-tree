import org.jahia.api.Constants
import org.jahia.tools.patches.LoggerWrapper
import org.jahia.services.content.*
import org.jahia.registries.ServicesRegistry
import org.springframework.context.annotation.ImportBeanDefinitionRegistrar

import javax.jcr.NodeIterator
import javax.jcr.RepositoryException
import javax.jcr.query.Query
import javax.jcr.PathNotFoundException

// String startPath = "/sites/mySite/home/page-1/page-11"
// boolean testOnly = true;
// boolean forcePublication = false;
// String nodeType = "jnt:content"

Set<String> nodesToAutoPublish = new HashSet<String>();
Set<String> nodesWithPendingModifications = new HashSet<String>();

if (testOnly) {
    logger.info("Test mode enabled: no update or publication is done.")
    logger.info("");
}
if (forcePublication) {
    logger.info("Force publication mode enabled: content with pending modification will be published.")
    logger.info("");
}
try {

    JCRTemplate.getInstance().doExecuteWithSystemSession(null, Constants.EDIT_WORKSPACE, new JCRCallback<Object>() {
        @Override
        public Object doInJCR(JCRSessionWrapper session) throws RepositoryException {
            try {
                JCRNodeWrapper start = session.getNode(startPath);
                def q = "select * from [" + nodeType + "] where isdescendantnode('" + startPath + "')";
                NodeIterator iterator = session.getWorkspace().getQueryManager().createQuery(q, Query.JCR_SQL2).execute().getNodes();
                while (iterator.hasNext()) {
                    final JCRNodeWrapper node = (JCRNodeWrapper) iterator.nextNode();
                    // check if node has pending updates
                    if (! hasPendingModification(node) || forcePublication) {
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
                if (! testOnly) {
                    session.save();
                }

            } catch (PathNotFoundException e) {
                log.info("Could not find the Start path " + startPath);
            }

            if (CollectionUtils.isNotEmpty(nodesToAutoPublish)) {
                if (! testOnly) {
                    JCRPublicationService.getInstance().publish(nodesToAutoPublish.asList(), Constants.EDIT_WORKSPACE, Constants.LIVE_WORKSPACE, false, null)
                };
                logger.info("");
                if (testOnly) {
                    logger.info("Nodes that would be republished (if the test mode is disabled:")
                } else {
                    logger.info("Nodes that were republished:")
                }
                for (String identifier : nodesToAutoPublish) {
                    logger.info("   " + session.getNodeByIdentifier(identifier).getPath());
                }
            }

            if (CollectionUtils.isNotEmpty(nodesWithPendingModifications)) {
                logger.info("");
                logger.info("Unpublished nodes (pending modification):")
                for (String identifier : nodesWithPendingModifications) {
                    logger.info("   " + session.getNodeByIdentifier(identifier).getPath());
                }
            }

        }
    });
} catch (Exception ex) {
    log.error("Script failed with exception", ex);
}


private boolean hasPendingModification(JCRNodeWrapper node) {
    if (!node.hasProperty("j:lastPublished")) return true
    if (!node.hasProperty("j:published") || !node.getProperty("j:published").getBoolean()) return true
    java.util.Calendar lastModified = node.getProperty("jcr:lastModified").getDate()
    java.util.Calendar lastPublished = node.getProperty("j:lastPublished").getDate()
    return lastModified > lastPublished
}
